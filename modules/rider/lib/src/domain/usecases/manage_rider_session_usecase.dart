import 'dart:async';
import 'package:rider/src/core/network/sync/rider_subscription_handler.dart';
import 'package:rider/src/data/datasources/rider_remote_datasource.dart';
import 'package:rider/src/domain/usecases/rider_heartbeat_component.dart';
import 'package:rider/src/domain/usecases/rider_sync_component.dart';
import 'package:rider/src/domain/usecases/sync_rider_data_usecase.dart';
import 'package:rider/src/presentation/bloc/rider_bloc.dart';
import 'package:shared/shared.dart';

/// Concrete session coordinator for the Rider module.
///
/// Replaces monolithic logic with pluggable components for assignment updates,
/// location heartbeats, push notifications, and background sync.
class RiderSessionManager extends SessionCoordinator {
  RiderSessionManager({
    required RiderRemoteDataSource dataSource,
    required RiderSubscriptionHandler subscriptionHandler,
    required RiderDao riderDao,
    required LogistixDatabase database,
    required SyncRiderDataUseCase syncUseCase,
    required RiderBloc riderBloc,
  }) {
    // 1. Assignment Stream
    addComponent(
      RealtimeSubscriptionComponent(
        name: 'assignments',
        subscribe: (onSync) => dataSource.subscribeToAssignmentUpdates(
          onData: (event, order, rider, metrics) =>
              subscriptionHandler.handleOrderUpdate(
                event,
                order,
                riderDto: rider,
                riderMetrics: metrics,
              ),
          onSync: onSync,
        ),
      ),
    );

    // 2. Location & Status Heartbeat
    addComponent(
      RiderHeartbeatComponent(
        dataSource: dataSource,
        riderDao: riderDao,
        riderBloc: riderBloc,
      ),
    );

    // 3. Data Synchronization
    addComponent(RiderSyncComponent(syncUseCase, database));

    // 4. Shared Infrastructure
    addComponent(
      PeriodicSyncComponent(
        interval: const Duration(minutes: 2),
        onTrigger: sync,
      ),
    );
  }

  /// Compatibility methods for manual control
  Future<void> startSession() => start();
  
  void stopSession() => stop();
}
