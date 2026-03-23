import 'package:bootstrap/interfaces/store/store.dart';
import 'package:rider/src/data/datasources/rider_remote_datasource.dart';
import 'package:shared/shared.dart';

/// Performs the initial data synchronization for the Rider module.
///
/// This encompasses:
/// 1. Fetching the latest [Rider] profile (`meRider`).
/// 2. Performing a catch-up sync for orders and metrics via [RiderRemoteDataSource].
/// 3. Populating the local database ([OrderDao], [RiderDao]).
class RiderInitialSyncProvider implements InitialSyncProvider {
  RiderInitialSyncProvider({
    required RiderRemoteDataSource remoteDataSource,
    required OrderDao orderDao,
    required RiderDao riderDao,
    required StreamableObjectStore<RiderMetricsDto> metricsStore,
    required LogistixDatabase database,
    required UserStore userStore,
  }) : _remoteDataSource = remoteDataSource,
       _orderDao = orderDao,
       _riderDao = riderDao,
       _metricsStore = metricsStore,
       _database = database,
       _userStore = userStore;

  final RiderRemoteDataSource _remoteDataSource;
  final OrderDao _orderDao;
  final RiderDao _riderDao;
  final StreamableObjectStore<RiderMetricsDto> _metricsStore;
  final LogistixDatabase _database;
  final UserStore _userStore;

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

    var offset = 0;
    const limit = 50;
    var hasMore = true;
    DateTime? completionTime;

    while (hasMore) {
      final syncDto = await _remoteDataSource.syncData(
        since: since,
        limit: limit,
        offset: offset,
      );

      completionTime = DateTime.fromMillisecondsSinceEpoch(syncDto.lastUpdated);

      // Batch upsert orders
      if (syncDto.orders.isNotEmpty) {
        await _orderDao.upsertOrders(
          syncDto.orders.map((e) => e.toDriftCompanion()).toList(),
        );
      }

      // Handle deletions
      if (syncDto.deletedOrderIds.isNotEmpty) {
        await _orderDao.deleteOrders(syncDto.deletedOrderIds);
      }

      // Update metrics store (at least from the first page)
      if (offset == 0) {
        await _metricsStore.set(syncDto.metrics);
      }

      if (syncDto.orders.length < limit) {
        hasMore = false;
      } else {
        offset += limit;
      }
    }

    // 3. Update Sync Time
    if (completionTime != null) {
      await _database.updateLastSyncTime('rider_last_sync', completionTime, null);
    }
  }
}
