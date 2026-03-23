import 'dart:async';

import 'package:bootstrap/interfaces/store/store.dart';
import 'package:dispatcher/src/core/network/sync/dispatcher_subscription_handler.dart';
import 'package:dispatcher/src/data/datasources/dispatcher_session_remote_datasource.dart';
import 'package:shared/shared.dart';

/// Manages dispatcher session with real-time subscriptions
///
/// Architecture:
/// - Subscriptions write to Drift via SubscriptionHandler
/// - Cubits subscribe to Drift streams for reactive updates
/// - No manual callbacks needed
class DispatcherSessionManager {
  DispatcherSessionManager(
    this._dataSource,
    this._subscriptionHandler,
    this._orderDao,
    this._riderDao,
    this._metricsStore,
    this._database,
  );

  final DispatcherSessionRemoteDataSource _dataSource;
  final ObjectStore<DispatcherMetricsDto> _metricsStore;
  final DispatcherSubscriptionHandler _subscriptionHandler;
  final LogistixDatabase _database;
  final OrderDao _orderDao;
  final RiderDao _riderDao;

  SyncManager? _orderSyncManager;
  SyncManager? _riderSyncManager;
  Timer? _syncTimer;
  bool _isSyncing = false;

  Future<void> start({required String companyId}) async {
    // 1. Subscribe to order updates (performs sync on connection and reconnection)
    _orderSyncManager = await _dataSource.subscribeToOrderUpdates(
      companyId: companyId,
      onData: (orderDto, eventType, metrics) async {
        await _subscriptionHandler.handleOrderUpdate(
          orderDto,
          eventType,
          dispatcherMetrics: metrics,
        );
      },
      onSync: _performSync,
    );

    // 2. Subscribe to rider updates (performs sync on connection and reconnection)
    _riderSyncManager = await _dataSource.subscribeToRiderUpdates(
      companyId: companyId,
      onData: (riderDto, eventType, metrics) async {
        await _subscriptionHandler.handleRiderUpdate(
          riderDto,
          eventType,
          dispatcherMetrics: metrics,
        );
      },
    );

    // 3. Start periodic sync every 5 minutes
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => _performSync(),
    );
  }

  Future<void> _performSync() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      final lastSyncTime = await _database.getLastSyncTime(
        'dispatcher_last_sync',
      );

      final since = lastSyncTime?.millisecondsSinceEpoch.toDouble();

      var offset = 0;
      const limit = 50;
      var hasMore = true;
      int? lastUpdated;

      while (hasMore) {
        try {
          final syncDto = await _dataSource.syncData(
            since: since,
            limit: limit,
            offset: offset,
          );

          lastUpdated = syncDto.lastUpdated;

          // Upsert orders in batch
          if (syncDto.orders.isNotEmpty) {
            await _orderDao.upsertOrders(
              syncDto.orders.map((e) => e.toDriftCompanion()).toList(),
            );
          }

          // Upsert riders in batch
          if (syncDto.riders.isNotEmpty) {
            await _riderDao.upsertRiders(
              syncDto.riders.map((e) => e.toDriftCompanion()).toList(),
            );
          }

          // Save metrics to ObjectStore (usually from first page is enough)
          if (offset == 0) {
            await _metricsStore.set(syncDto.metrics);
          }

          // Handle deleted orders
          if (syncDto.deletedOrderIds.isNotEmpty) {
            await _orderDao.deleteOrders(syncDto.deletedOrderIds);
          }

          // Handle deleted riders
          if (syncDto.deletedRiderIds.isNotEmpty) {
            await _riderDao.deleteRiders(syncDto.deletedRiderIds);
          }

          if (syncDto.orders.length < limit && syncDto.riders.length < limit) {
            hasMore = false;
          } else {
            offset += limit;
          }
        } catch (e) {
          // Log page error but allow the next page or retry to handle it.
          // For crucial syncs, we might want to throw or retry here.
          // In a real app, we'd log to Sentry.
          hasMore = false; // Stop this sync cycle if a page fails
          rethrow;
        }
      }

      // Update last sync time immediately after a successful page fetch
      if (lastUpdated != null) {
        await _database.updateLastSyncTime(
          'dispatcher_last_sync',
          DateTime.fromMillisecondsSinceEpoch(lastUpdated),
          null,
        );
      }
    } catch (e) {
      // Handle overall sync error
    } finally {
      _isSyncing = false;
    }
  }

  void stop() {
    _orderSyncManager?.stop();
    _orderSyncManager = null;
    _riderSyncManager?.stop();
    _riderSyncManager = null;
    _syncTimer?.cancel();
    _syncTimer = null;
  }
}
