import 'dart:async';

import 'package:bootstrap/interfaces/store/store.dart';
import 'package:geolocator/geolocator.dart';
import 'package:rider/src/core/network/sync/rider_subscription_handler.dart';
import 'package:rider/src/data/datasources/rider_remote_datasource.dart';
import 'package:rider/src/presentation/bloc/rider_bloc.dart';
import 'package:rider/src/presentation/bloc/rider_event.dart';
import 'package:shared/shared.dart';

/// Manages rider session with real-time subscriptions
///
/// Architecture:
/// - Subscriptions write to Drift via SubscriptionHandler
/// - Heartbeat updates location and syncs data to Drift
/// - Cubits subscribe to Drift streams for reactive updates
class RiderSessionManager {
  RiderSessionManager(
    this._dataSource,
    this._subscriptionHandler,
    this._orderDao,
    this._riderDao,
    this._metricsStore,
    this._database,
    this.riderBloc,
  );

  final RiderRemoteDataSource _dataSource;
  final RiderSubscriptionHandler _subscriptionHandler;
  final OrderDao _orderDao;
  final RiderDao _riderDao;
  final ObjectStore<RiderMetricsDto> _metricsStore;
  final LogistixDatabase _database;
  final RiderBloc riderBloc;

  SyncManager? _assignmentSyncManager;
  Timer? _heartbeatTimer;
  Timer? _syncTimer;
  bool _isSyncing = false;

  Future<void> startSession(String riderId) async {
    // 1. Subscribe to order updates
    _assignmentSyncManager = await _dataSource.subscribeToAssignmentUpdates(
      riderId: riderId,
      onData:
          (
            OrderDto orderDto,
            RiderDto? riderDto,
            String eventType,
            RiderMetricsDto? metrics,
          ) async {
            // Write to Drift via SubscriptionHandler
            await _subscriptionHandler.handleOrderUpdate(
              orderDto,
              eventType,
              riderDto: riderDto,
              riderMetrics: metrics,
            );
          },
      onSync: _performSync,
    );

    // Initial sync
    unawaited(_performSync());

    // Start partial sync every 5 minutes
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => _performSync(),
    );
  }

  /// Start or resume the heartbeat (location updates)
  void startHeartbeat(String riderId) {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(
      const Duration(seconds: 20),
      (_) => _sendHeartbeat(riderId),
    );

    // Immediate heartbeat to set correct online/busy status on server
    unawaited(_sendHeartbeat(riderId));
  }

  /// Stop only the heartbeat
  void stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  Future<void> _performSync() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      final lastSyncTime = await _database.getLastSyncTime('rider_last_sync');
      final since = lastSyncTime?.millisecondsSinceEpoch.toDouble();

      var offset = 0;
      const limit = 50;
      var hasMore = true;

      while (hasMore) {
        try {
          final syncDto = await _dataSource.syncData(
            since: since,
            limit: limit,
            offset: offset,
          );

          if (riderBloc.isClosed) return;

          // Update last sync time immediately after a successful page fetch
          await _database.updateLastSyncTime(
            'rider_last_sync',
            DateTime.fromMillisecondsSinceEpoch(syncDto.lastUpdated),
            null,
          );

          // Upsert full list of active/available orders
          if (syncDto.orders.isNotEmpty) {
            await _orderDao.upsertOrders(
              syncDto.orders.map((e) => e.toDriftCompanion()).toList(),
            );
          }

          // Upsert metrics
          await _metricsStore.set(syncDto.metrics);

          // If there are deleted orders, remove them
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
    } catch (_) {
      // Handle overall sync error
    } finally {
      _isSyncing = false;
    }
  }

  Future<RiderDto?> _sendHeartbeat(String riderId) async {
    try {
      final position = await Geolocator.getCurrentPosition();

      final riderDto = await _dataSource.sendHeartbeat(
        lat: position.latitude,
        lng: position.longitude,
      );

      if (riderBloc.isClosed) return null;

      riderBloc.add(RiderEvent.locationUpdated(position));

      // Update local DB with latest rider info (including status)
      await _riderDao.upsertRider(riderDto.toDriftCompanion());

      // Update bloc status from heartbeat result
      final status = RiderStatusX.fromString(riderDto.status);
      riderBloc.add(RiderEvent.statusChanged(status));

      return riderDto;
    } catch (_) {
      // Permission or service issue - ignore
      return null;
    }
  }

  /// Stop the session
  void stopSession() {
    _assignmentSyncManager?.stop();
    _assignmentSyncManager = null;
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    _syncTimer?.cancel();
    _syncTimer = null;
  }
}
