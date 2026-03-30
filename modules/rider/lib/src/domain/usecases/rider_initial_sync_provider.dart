import 'package:rider/src/data/datasources/rider_remote_datasource.dart';
import 'package:rider/src/domain/usecases/sync_rider_data_usecase.dart';
import 'package:shared/shared.dart';

/// Performs the initial data synchronization for the Rider module.
///
/// This encompasses:
/// 1. Fetching the latest [Rider] profile (`meRider`).
/// 2. Performing a catch-up sync for orders and metrics via [RiderRemoteDataSource].
/// 3. Populating the local database ([OrderDao], [RiderDao]).
class RiderInitialSyncProvider implements InitialSyncProvider {
  RiderInitialSyncProvider({
    required RiderDao riderDao,
    required UserStore userStore,
    required LogistixDatabase database,
    required SyncRiderDataUseCase syncRiderDataUseCase,
  }) : _riderDao = riderDao,
       _userStore = userStore,
       _database = database,
       _syncRiderDataUseCase = syncRiderDataUseCase;

  final RiderDao _riderDao;
  final UserStore _userStore;
  final LogistixDatabase _database;
  final SyncRiderDataUseCase _syncRiderDataUseCase;

  @override
  Future<void> performInitialSync() async {
    // 1. Get Rider Profile from Local Store (fetched during startup/login)
    final user = await _userStore.getUser();
    final riderProfile = user?.riderProfile;
    
    if (riderProfile != null) {
      await _riderDao.upsertRider(
        RiderDto.fromEntity(riderProfile).toDriftCompanion(),
      );
    }

    // 2. Perform Catch-up Sync (Orders & Metrics)
    final lastSyncTime = await _database.getLastSyncTime('rider_last_sync');
    final since = lastSyncTime?.millisecondsSinceEpoch.toDouble();

    await _syncRiderDataUseCase(since: since);
  }
}
