import 'package:bootstrap/interfaces/store/store.dart';
import 'package:dispatcher/src/data/datasources/dispatcher_session_remote_datasource.dart';
import 'package:shared/shared.dart';

/// Performs a full catch-up sync for the Dispatcher module.
/// 
/// This logic is shared between the InitialSyncProvider (during bootstrap)
/// and the DispatcherSessionManager (during live background polling).
class SyncDispatcherDataUseCase {
  SyncDispatcherDataUseCase({
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
  final StreamableObjectStore<DispatcherMetricsDto> _metricsStore;
  final LogistixDatabase _database;

  Future<void> call({double? since, int limit = 50}) async {
    var offset = 0;
    var hasMore = true;
    DateTime? completionTime;

    while (hasMore) {
      final syncDto = await _remoteDataSource.syncData(
        since: since,
        limit: limit,
        offset: offset,
      );

      completionTime = DateTime.fromMillisecondsSinceEpoch(syncDto.lastUpdated);

      // Parallelize local DB updates for efficiency
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
        
        // Persist materialized metrics to local DB
        if (offset == 0 && (syncDto.riders.isNotEmpty || syncDto.orders.isNotEmpty)) 
          _database.upsertDispatcherMetrics(
            syncDto.metrics.toDriftCompanion(syncDto.riders.firstOrNull?.companyId ?? syncDto.orders.firstOrNull?.companyId ?? 'unknown')
          ),

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
      await _database.updateLastSyncTime('dispatcher_last_sync', completionTime, null);
    }
  }
}
