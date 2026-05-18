import 'dart:async';

import 'package:customer/src/core/network/sync/customer_subscription_handler.dart';
import 'package:customer/src/data/datasources/delivery_remote_datasource.dart';
import 'package:customer/src/domain/usecases/sync_customer_data_usecase.dart';
import 'package:shared/shared.dart';

/// Manages customer session with real-time subscriptions
class CustomerSessionManager {
  CustomerSessionManager(
    this._dataSource,
    this._subscriptionHandler,
    this._database,
    this._syncCustomerDataUseCase,
  );

  final CustomerDeliveryRemoteDataSource _dataSource;
  final CustomerSubscriptionHandler _subscriptionHandler;
  final LogistixDatabase _database;
  final SyncCustomerDataUseCase _syncCustomerDataUseCase;

  SyncManager? _deliverySyncManager;
  Timer? _syncTimer;
  bool _isSyncing = false;

  Future<void> start() async {
    // 1. Subscribe to delivery updates (performs sync on connection and reconnection)
    _deliverySyncManager = await _dataSource.subscribeToUpdates(
      onData: (deliveryDto, SubscriptionEventType eventType) async {
        await _subscriptionHandler.handleDeliveryUpdate(eventType.name, deliveryDto);
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

      await _syncCustomerDataUseCase(since: since);
    } catch (e) {
      // Handle overall sync error
    } finally {
      _isSyncing = false;
    }
  }

  void stop() {
    _deliverySyncManager?.stop();
    _deliverySyncManager = null;
    _syncTimer?.cancel();
    _syncTimer = null;
  }
}
