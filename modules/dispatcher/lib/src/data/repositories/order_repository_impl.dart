import 'package:bootstrap/definitions/app_error.dart';
import 'package:bootstrap/definitions/result.dart';
import 'package:dispatcher/src/data/datasources/order_remote_datasource.dart';
import 'package:dispatcher/src/domain/repositories/order_repository.dart';
import 'package:shared/shared.dart';

class OrderRepositoryImpl implements OrderRepository {
  const OrderRepositoryImpl(this._dataSource);
  final OrderRemoteDataSource _dataSource;

  @override
  Future<Result<AppError, List<Order>>> getOrders({
    List<String>? status,
    String? searchQuery,
    int limit = 20,
    int offset = 0,
  }) async {
    return Result.tryCatch(() async {
      final dtos = await _dataSource.getOrders(
        status: status,
        searchQuery: searchQuery,
        limit: limit,
        offset: offset,
      );
      return dtos.map((dto) => dto.toEntity()).toList();
    });
  }

  @override
  Future<Result<AppError, Order>> createOrder(OrderCreateInput input) async {
    return Result.tryCatch(() async {
      final dto = await _dataSource.createOrder(input);
      return dto.toEntity();
    });
  }

  @override
  Future<Result<AppError, List<Order>>> createBulkOrders(
    List<OrderCreateInput> orders,
  ) async {
    return Result.tryCatch(() async {
      final dtos = await _dataSource.createBulkOrders(orders);
      return dtos.map((dto) => dto.toEntity()).toList();
    });
  }

  @override
  Future<Result<AppError, Order>> getOrder(String id) async {
    return Result.tryCatch(() async {
      final dto = await _dataSource.getOrder(id);
      return dto.toEntity();
    });
  }

  @override
  Future<Result<AppError, void>> updateOrderStatus(
    String orderId,
    OrderStatus status,
  ) async {
    return Result.tryCatch(
      () => _dataSource.updateOrderStatus(orderId, status.value),
    );
  }

  @override
  Future<Result<AppError, void>> assignRider(
    String orderId,
    String riderId,
  ) async {
    return Result.tryCatch(() => _dataSource.assignOrder(orderId, riderId));
  }

  @override
  Future<Result<AppError, void>> cancelOrder(String orderId) async {
    return Result.tryCatch(
      () => _dataSource.updateOrderStatus(orderId, OrderStatus.cancelled.value),
    );
  }

  @override
  Future<Result<AppError, List<OrderCreateInput>>> parseTextToOrders(
    String text,
  ) async {
    return Result.tryCatch(() => _dataSource.parseTextToOrders(text));
  }
}
