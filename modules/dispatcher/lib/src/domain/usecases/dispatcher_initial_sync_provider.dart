import 'package:adapters/adapters.dart';
import 'package:dispatcher/src/data/datasources/dispatcher_session_remote_datasource.dart';
import 'package:dispatcher/src/domain/usecases/sync_dispatcher_data_usecase.dart';
import 'package:shared/shared.dart';

/// Performs the initial data synchronization for the Dispatcher module.
///
/// This encompasses:
/// 1. Performing a catch-up sync for orders, riders, and metrics via [DispatcherSessionRemoteDataSource].
/// 2. Populating the local database ([OrderDao], [RiderDao]).
/// 3. Updating the [DispatcherMetricsDto] store.
class DispatcherInitialSyncProvider implements InitialSyncProvider {
  DispatcherInitialSyncProvider({
    required LogistixDatabase database,
    required SyncDispatcherDataUseCase syncDispatcherDataUseCase,
  }) : _database = database,
       _syncDispatcherDataUseCase = syncDispatcherDataUseCase;

  final LogistixDatabase _database;
  final SyncDispatcherDataUseCase _syncDispatcherDataUseCase;

  @override
  Future<void> performInitialSync() async {
    final lastSyncTime = await _database.getLastSyncTime(
      'dispatcher_last_sync',
    );

    final since = lastSyncTime?.millisecondsSinceEpoch.toDouble();

    try {
      await _syncDispatcherDataUseCase(since: since);
    } catch (e, s) {
      appLogger.exception(e, stack: s);
    }
  }
}
