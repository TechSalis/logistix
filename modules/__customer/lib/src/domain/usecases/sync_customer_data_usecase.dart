import '../../data/datasources/order_remote_datasource.dart';
import 'package:shared/shared.dart';

/// Performs a full catch-up sync for the Customer module.
/// 
/// This logic is shared between the InitialSyncProvider (during bootstrap)
/// and the CustomerSessionManager (during live background polling).
class SyncCustomerDataUseCase {
  SyncCustomerDataUseCase({
    required CustomerOrderRemoteDataSource remoteDataSource,
    required OrderDao orderDao,
    required LogistixDatabase database,
  }) : _remoteDataSource = remoteDataSource,
       _orderDao = orderDao,
       _database = database;

  final CustomerOrderRemoteDataSource _remoteDataSource;
  final OrderDao _orderDao;
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

      // Upsert orders in batch
      if (syncDto.orders.isNotEmpty) {
        await _orderDao.upsertOrders(
          syncDto.orders.map((e) => e.toDriftCompanion()).toList(),
        );
      }

      // Handle deleted orders
      if (syncDto.deletedOrderIds.isNotEmpty) {
        await _orderDao.deleteOrders(syncDto.deletedOrderIds);
      }

      if (syncDto.orders.length < limit) {
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
