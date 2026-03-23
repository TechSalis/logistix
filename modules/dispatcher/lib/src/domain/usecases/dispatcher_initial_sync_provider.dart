import 'package:adapters/adapters.dart';
import 'package:bootstrap/interfaces/store/store.dart';
import 'package:dispatcher/src/data/datasources/dispatcher_session_remote_datasource.dart';
import 'package:shared/shared.dart';

/// Performs the initial data synchronization for the Dispatcher module.
///
/// This encompasses:
/// 1. Performing a catch-up sync for orders, riders, and metrics via [DispatcherSessionRemoteDataSource].
/// 2. Populating the local database ([OrderDao], [RiderDao]).
/// 3. Updating the [DispatcherMetricsDto] store.
class DispatcherInitialSyncProvider implements InitialSyncProvider {
  DispatcherInitialSyncProvider({
    required DispatcherSessionRemoteDataSource remoteDataSource,
    required OrderDao orderDao,
    required RiderDao riderDao,
    required StreamableObjectStore<DispatcherMetricsDto> metricsStore,
    required LogistixDatabase database,
  }) : _remoteDataSource = remoteDataSource,
       _orderDao = orderDao,
       _riderDao = riderDao,
       _metricsStore = metricsStore,
       _database = database;

  final DispatcherSessionRemoteDataSource _remoteDataSource;
  final OrderDao _orderDao;
  final RiderDao _riderDao;
  final LogistixDatabase _database;
  final StreamableObjectStore<DispatcherMetricsDto> _metricsStore;

  @override
  Future<void> performInitialSync() async {
    final lastSyncTime = await _database.getLastSyncTime(
      'dispatcher_last_sync',
    );

    final since = lastSyncTime?.millisecondsSinceEpoch.toDouble();

    var offset = 0;
    const limit = 50;
    var hasMore = true;
    DateTime? completionTime;

    try {
      while (hasMore) {
        final syncDto = await _remoteDataSource.syncData(
          since: since,
          limit: limit,
          offset: offset,
        );

        completionTime = DateTime.fromMillisecondsSinceEpoch(
          syncDto.lastUpdated,
        );

        // Optimization: Parallelize all local DB updates for the sync batch
        await Future.wait([
          if (syncDto.orders.isNotEmpty)
            _orderDao.upsertOrders(
              syncDto.orders.map((e) => e.toDriftCompanion()).toList(),
            ),
          if (syncDto.riders.isNotEmpty)
            _riderDao.upsertRiders(
              syncDto.riders.map((e) => e.toDriftCompanion()).toList(),
            ),
          if (syncDto.deletedOrderIds.isNotEmpty)
            _orderDao.deleteOrders(syncDto.deletedOrderIds),
          if (syncDto.deletedRiderIds.isNotEmpty)
            _riderDao.deleteRiders(syncDto.deletedRiderIds),
          if (offset == 0) _metricsStore.set(syncDto.metrics),
        ]);

        if (syncDto.orders.length < limit && syncDto.riders.length < limit) {
          hasMore = false;
        } else {
          offset += limit;
        }
      }

      // Update Sync Time
      if (completionTime != null) {
        await _database.updateLastSyncTime(
          'dispatcher_last_sync',
          completionTime,
          null,
        );
      }
    } catch (e, s) {
      appLogger.exception(e, stack: s);
    } finally {
      hasMore = false;
    }
  }
}
