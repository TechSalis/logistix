import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:rider/src/core/network/sync/rider_subscription_handler.dart';
import 'package:rider/src/data/datasources/rider_remote_datasource.dart';
import 'package:rider/src/domain/usecases/sync_rider_data_usecase.dart';
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
    this._riderDao,
    this._database,
    this._syncRiderDataUseCase,
    this.riderBloc,
  );

  final RiderRemoteDataSource _dataSource;
  final RiderSubscriptionHandler _subscriptionHandler;
  final RiderDao _riderDao;
  final LogistixDatabase _database;
  final SyncRiderDataUseCase _syncRiderDataUseCase;
  final RiderBloc riderBloc;

  SyncManager? _assignmentSyncManager;
  Timer? _heartbeatTimer;
  Timer? _syncTimer;
  bool _isSyncing = false;

  Future<void> startSession() async {
    // 1. Subscribawait
    await Future.wait<void>([
      _sendHeartbeat(),
      _dataSource
          .subscribeToAssignmentUpdates(
            onData:
                (
                  OrderDto? orderDto,
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
          )
          .then((value) => _assignmentSyncManager = value),
    ]);

    // Start partial sync every 1 minute
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => _performSync(),
    );
  }

  /// Start or resume the heartbeat (location updates)
  void startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _sendHeartbeat(),
    );
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

      await _syncRiderDataUseCase(since: since);
    } catch (_) {
      // Handle overall sync error
    } finally {
      _isSyncing = false;
    }
  }

  Future<RiderDto?> _sendHeartbeat() async {
    try {
      Position? position;
      try {
        final isEnabled = await Geolocator.isLocationServiceEnabled();
        if (isEnabled) {
          position = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              timeLimit: Duration(seconds: 3),
            ),
          );
        }
      } catch (_) {
        // Fallback gracefully without location
      }

      final riderDto = await _dataSource.sendHeartbeat(
        lat: position?.latitude,
        lng: position?.longitude,
      );

      if (riderBloc.isClosed) return null;

      if (position != null) {
        riderBloc.add(RiderEvent.locationUpdated(position));
      }

      // Update local DB with latest rider info (including status)
      await _riderDao.upsertRider(riderDto.toDriftCompanion());

      // Update bloc status from heartbeat result
      final status = RiderStatusX.fromString(riderDto.status);
      riderBloc.add(RiderEvent.statusChanged(status));

      return riderDto;
    } catch (e) {
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
