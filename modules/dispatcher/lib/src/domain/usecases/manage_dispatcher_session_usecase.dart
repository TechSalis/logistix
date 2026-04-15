import 'package:dispatcher/src/core/network/sync/dispatcher_subscription_handler.dart';
import 'package:dispatcher/src/data/datasources/dispatcher_session_remote_datasource.dart';
import 'package:dispatcher/src/domain/usecases/dispatcher_sync_component.dart';
import 'package:dispatcher/src/domain/usecases/sync_dispatcher_data_usecase.dart';
import 'package:dispatcher/src/features/chat/domain/usecases/chat_session_manager.dart';
import 'package:shared/shared.dart';

/// Concrete session coordinator for the Dispatcher module.
/// 
/// Instead of monolithic logic, it configures a list of [SessionComponent]s
/// to handle orders, riders, chat, notifications, and periodic sync.
class DispatcherSessionManager extends SessionCoordinator {
  DispatcherSessionManager({
    required DispatcherSessionRemoteDataSource dataSource,
    required DispatcherSubscriptionHandler subscriptionHandler,
    required LogistixDatabase database,
    required SyncDispatcherDataUseCase syncUseCase,
    required ChatSessionManager chatSessionManager,
  }) {
    // 1. Core Data Synchronization
    addComponent(DispatcherSyncComponent(syncUseCase, database));
    
    // 2. Orders Real-time Stream
    addComponent(
      RealtimeSubscriptionComponent(
        name: 'orders',
        subscribe: (onSync) => dataSource.subscribeToOrderUpdates(
          onData: (order, event, metrics) => subscriptionHandler
              .handleOrderUpdate(event, order,
          dispatcherMetrics: metrics,
        ),
          onSync: onSync,
        ),
      ),
    );

    // 3. Riders Real-time Stream
    addComponent(
      RealtimeSubscriptionComponent(
        name: 'riders',
        subscribe: (onSync) => dataSource.subscribeToRiderUpdates(
          onData: (rider, event, metrics) => subscriptionHandler
              .handleRiderUpdate(rider, event,
          dispatcherMetrics: metrics,
        ),
        ),
      ),
    );

    // 4. Chat Feature
    addComponent(chatSessionManager);

    addComponent(
      PeriodicSyncComponent(interval: const Duration(minutes: 2), onTrigger: sync),
    );
  }
}
