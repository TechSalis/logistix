import 'package:adapters/adapters.dart';
import 'package:customer/src/data/datasources/order_remote_datasource.dart';
import 'package:shared/shared.dart';

/// Performs the initial data synchronization for the Customer module.
class CustomerInitialSyncProvider implements InitialSyncProvider {
  CustomerInitialSyncProvider({
    required CustomerOrderRemoteDataSource remoteDataSource,
    required OrderDao orderDao,
    required LogistixDatabase database,
  }) : _remoteDataSource = remoteDataSource,
       _orderDao = orderDao,
       _database = database;

  final CustomerOrderRemoteDataSource _remoteDataSource;
  final OrderDao _orderDao;
  final LogistixDatabase _database;

  @override
  Future<void> performInitialSync() async {
    final lastSyncTime = await _database.getLastSyncTime(
      'customer_last_sync',
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

        await Future.wait([
          if (syncDto.orders.isNotEmpty)
            _orderDao.upsertOrders(
              syncDto.orders.map((e) => e.toDriftCompanion()).toList(),
            ),
          if (syncDto.deletedOrderIds.isNotEmpty)
            _orderDao.deleteOrders(syncDto.deletedOrderIds),
        ]);

        if (syncDto.orders.length < limit) {
          hasMore = false;
        } else {
          offset += limit;
        }
      }

      if (completionTime != null) {
        await _database.updateLastSyncTime(
          'customer_last_sync',
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
