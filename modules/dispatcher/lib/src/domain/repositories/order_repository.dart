import 'package:bootstrap/definitions/app_error.dart';
import 'package:bootstrap/definitions/result.dart';
import 'package:dispatcher/src/data/dtos/order_create_input.dart';
import 'package:shared/shared.dart';

abstract class OrderRepository {
  // Read operations - return streams from local DB
  Stream<List<Order>> watchOrders({
    List<OrderStatus>? status,
    String? searchQuery,
    int limit = 20,
    int offset = 0,
  });

  Stream<Order?> watchOrder(String id);

  Stream<int> watchOrderCount({List<OrderStatus>? status});

  // Write operations - return futures (go to server)
  Future<Result<AppError, List<Order>>> createBulkOrders(
    List<OrderCreateInput> orders,
  );

  Future<Result<AppError, void>> updateOrderStatus(
    String orderId,
    OrderStatus status,
  );

  Future<Result<AppError, void>> assignRider(String orderId, Rider rider);

  Future<Result<AppError, void>> unassignRider(String orderId);

  Future<Result<AppError, void>> cancelOrder(String orderId);

  // Utility operations
  Future<Result<AppError, List<OrderCreateInput>>> parseTextToOrders(
    String text,
  );
}
