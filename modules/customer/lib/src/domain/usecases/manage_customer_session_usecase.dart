import 'dart:async';

import 'package:customer/src/core/network/sync/customer_subscription_handler.dart';
import 'package:customer/src/data/datasources/order_remote_datasource.dart';
import 'package:shared/shared.dart';

/// Manages customer session with real-time subscriptions
class CustomerSessionManager {
  CustomerSessionManager(
    this._dataSource,
    this._subscriptionHandler,
    this._orderDao,
    this._database,
  );

  final CustomerOrderRemoteDataSource _dataSource;
  final CustomerSubscriptionHandler _subscriptionHandler;
  final LogistixDatabase _database;
  final OrderDao _orderDao;

  SyncManager? _orderSyncManager;
  Timer? _syncTimer;
  bool _isSyncing = false;

  Future<void> start({required String userId}) async {
    // 1. Subscribe to order updates (performs sync on connection and reconnection)
    _orderSyncManager = await _dataSource.subscribeToUpdates(
      userId: userId,
      onData: (orderDto, SubscriptionEventType eventType) async {
        await _subscriptionHandler.handleOrderUpdate(
          orderDto,
          eventType.name.toUpperCase(),
        );
      },
      onSync: _performSync,
    );

    // 2. Start periodic sync every 5 minutes
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
        'customer_last_sync',
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

          // Handle deleted orders
          if (syncDto.deletedOrderIds.isNotEmpty) {
            await _orderDao.deleteOrders(syncDto.deletedOrderIds);
          }

          if (syncDto.orders.length < limit) {
            hasMore = false;
          } else {
            offset += limit;
          }
        } catch (e) {
          hasMore = false;
          rethrow;
        }
      }

      // Update last sync time immediately after a successful page fetch
      if (lastUpdated != null) {
        await _database.updateLastSyncTime(
          'customer_last_sync',
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
    _syncTimer?.cancel();
    _syncTimer = null;
  }
}
