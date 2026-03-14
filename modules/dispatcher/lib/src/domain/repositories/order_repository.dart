import 'package:bootstrap/definitions/app_error.dart';
import 'package:bootstrap/definitions/result.dart';
import 'package:shared/shared.dart';

abstract class OrderRepository {
  Future<Result<AppError, List<Order>>> getOrders({
    List<String>? status,
    String? searchQuery,
    int limit = 20,
    int offset = 0,
  });

  Future<Result<AppError, Order>> createOrder(OrderCreateInput input);

  Future<Result<AppError, List<Order>>> createBulkOrders(
    List<OrderCreateInput> orders,
  );

  Future<Result<AppError, Order>> getOrder(String id);
  Future<Result<AppError, void>> updateOrderStatus(
    String orderId,
    OrderStatus status,
  );
  Future<Result<AppError, void>> assignRider(String orderId, String riderId);
  Future<Result<AppError, void>> cancelOrder(String orderId);

  Future<Result<AppError, List<OrderCreateInput>>> parseTextToOrders(
    String text,
  );
}
