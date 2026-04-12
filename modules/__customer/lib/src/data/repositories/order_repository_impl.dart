import 'package:bootstrap/definitions/app_error.dart';
import 'package:bootstrap/definitions/result.dart';
import 'package:customer/src/data/datasources/order_remote_datasource.dart';
import 'package:customer/src/data/dtos/customer_order_input.dart';
import 'package:customer/src/domain/repositories/customer_order_repository.dart';
import 'package:shared/shared.dart';

class CustomerOrderRepositoryImpl implements CustomerOrderRepository {
  const CustomerOrderRepositoryImpl({
    required CustomerOrderRemoteDataSource remoteDataSource,
    required OrderDao orderDao,
    required UserStore userStore,
  }) : _remoteDataSource = remoteDataSource,
       _orderDao = orderDao,
       _userStore = userStore;

  final CustomerOrderRemoteDataSource _remoteDataSource;
  final OrderDao _orderDao;
  final UserStore _userStore;

  @override
  Stream<List<Order>> watchOrders({int limit = 20, int offset = 0}) {
    final userId = _userStore.user?.id;
    return _orderDao.watchOrders(
      createdBy: userId,
      limit: limit,
      offset: offset,
    );
  }

  @override
  Stream<Order?> watchOrder(String id) => _orderDao.watchOrder(id);

  @override
  Future<Result<AppError, Order>> createOrder(CustomerOrderInput input) async {
    return Result.tryCatch(() async {
      final dto = await _remoteDataSource.createOrder(input);
      
      // Save to local DB promptly
      await _orderDao.upsertOrder(dto.toDriftCompanion());
      
      return dto.toEntity();
    });
  }
}
