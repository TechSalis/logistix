import 'package:customer/src/data/datasources/delivery_remote_datasource.dart';
import 'package:shared/shared.dart';

/// Performs a full catch-up sync for the Customer module.
/// 
/// This logic is shared between the InitialSyncProvider (during bootstrap)
/// and the CustomerSessionManager (during live background polling).
class SyncCustomerDataUseCase {
  SyncCustomerDataUseCase({
    required CustomerDeliveryRemoteDataSource remoteDataSource,
    required DeliveryDao deliveryDao,
    required LogistixDatabase database,
  }) : _remoteDataSource = remoteDataSource,
       _deliveryDao = deliveryDao,
       _database = database;

  final CustomerDeliveryRemoteDataSource _remoteDataSource;
  final DeliveryDao _deliveryDao;
  final LogistixDatabase _database;

  Future<void> call({double? since, int limit = 50}) async {
    var offset = 0;
    var hasMore = true;
    int? lastUpdated;

    while (hasMore) {
      final syncDto = await _remoteDataSource.syncData(
        since: since,
        limit: limit,
        offset: offset,
      );

      lastUpdated = syncDto.lastUpdated;

      // Upsert deliveries in batch
      if (syncDto.deliveries.isNotEmpty) {
        await _deliveryDao.upsertDeliveries(
          syncDto.deliveries.map((e) => e.toDriftCompanion()).toList(),
        );
      }

      // Handle deleted deliveries
      if (syncDto.deletedDeliveryIds.isNotEmpty) {
        await _deliveryDao.deleteDeliveries(syncDto.deletedDeliveryIds);
      }

      if (syncDto.deliveries.length < limit) {
        hasMore = false;
      } else {
        offset += limit;
      }
    }

    // Update last sync time
    if (lastUpdated != null) {
      await _database.updateLastSyncTime(
        'customer_last_sync',
        DateTime.fromMillisecondsSinceEpoch(lastUpdated),
        null,
      );
    }
  }
}
