import 'package:bootstrap/interfaces/store/store.dart';
import 'package:rider/src/data/datasources/rider_remote_datasource.dart';
import 'package:shared/shared.dart';

/// Performs a full catch-up sync for the Rider module.
/// 
/// This logic is shared between the InitialSyncProvider (during bootstrap)
/// and the RiderSessionManager (during live background polling).
class SyncRiderDataUseCase {
  SyncRiderDataUseCase({
    required RiderRemoteDataSource remoteDataSource,
    required OrderDao orderDao,
    required RiderDao riderDao,
    required StreamableObjectStore<RiderMetricsDto> metricsStore,
    required LogistixDatabase database,
  })  : _remoteDataSource = remoteDataSource,
        _orderDao = orderDao,
        _riderDao = riderDao,
        _metricsStore = metricsStore,
        _database = database;

  final RiderRemoteDataSource _remoteDataSource;
  final OrderDao _orderDao;
  final RiderDao _riderDao;
  final StreamableObjectStore<RiderMetricsDto> _metricsStore;
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

      // Batch upsert orders and update profile
      await Future.wait([
        if (syncDto.orders.isNotEmpty)
          _orderDao.upsertOrders(
            syncDto.orders.map((e) => e.toDriftCompanion()).toList(),
          ),
        if (offset == 0) _riderDao.upsertRider(syncDto.rider.toDriftCompanion()),
        if (offset == 0) _metricsStore.set(syncDto.metrics),
      ]);

      // Handle deletions
      if (syncDto.deletedOrderIds.isNotEmpty) {
        await _orderDao.deleteOrders(syncDto.deletedOrderIds);
      }

      if (syncDto.orders.length < limit) {
        hasMore = false;
      } else {
        offset += limit;
      }
    }

    // Update Sync Time
    if (completionTime != null) {
      await _database.updateLastSyncTime(
        'rider_last_sync',
        completionTime,
        null,
      );
    }
  }
}
