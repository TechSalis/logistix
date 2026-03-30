import 'dart:async';

import 'package:dispatcher/src/core/network/sync/dispatcher_subscription_handler.dart';
import 'package:dispatcher/src/data/datasources/dispatcher_session_remote_datasource.dart';
import 'package:dispatcher/src/domain/usecases/sync_dispatcher_data_usecase.dart';
import 'package:shared/shared.dart';

/// Manages dispatcher session with real-time subscriptions
///
/// Architecture:
/// - Subscriptions write to Drift via SubscriptionHandler
class DispatcherSessionManager {
  DispatcherSessionManager(
    this._dataSource,
    this._subscriptionHandler,
    this._database,
    this._syncDispatcherDataUseCase,
    this._capturedOrderRepository,
  );

  final DispatcherSessionRemoteDataSource _dataSource;
  final DispatcherSubscriptionHandler _subscriptionHandler;
  final LogistixDatabase _database;
  final SyncDispatcherDataUseCase _syncDispatcherDataUseCase;
  final CapturedOrderRepository _capturedOrderRepository;

  SyncManager? _orderSyncManager;
  SyncManager? _riderSyncManager;
  Timer? _syncTimer;
  bool _isSyncing = false;

  Future<void> start() async {
    // 1. Subscribe to order updates (performs sync on connection and reconnection)
    _orderSyncManager = await _dataSource.subscribeToOrderUpdates(
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
      onData: (riderDto, eventType, metrics) async {
        await _subscriptionHandler.handleRiderUpdate(
          riderDto,
          eventType,
          dispatcherMetrics: metrics,
        );
      },
    );

    // 3. Start periodic sync every 60 seconds (as fallback if subscriptions fail)
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => _performSync(),
    );

    // 4. Background sync of captured orders
    unawaited(_capturedOrderRepository.syncBatches(threshold: 10));
  }

  Future<void> _performSync() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      final lastSyncTime = await _database.getLastSyncTime(
        'dispatcher_last_sync',
      );

      final since = lastSyncTime?.millisecondsSinceEpoch.toDouble();

      await _syncDispatcherDataUseCase(since: since);
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
