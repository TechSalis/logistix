import 'package:bootstrap/definitions/app_error.dart';
import 'package:bootstrap/definitions/result.dart';
import 'package:customer/src/data/dtos/customer_order_input.dart';
import 'package:shared/shared.dart';

abstract class CustomerOrderRepository {
  // Reactive reads (from local DB)
  Stream<List<Order>> watchOrders({int limit = 20, int offset = 0});
  Stream<Order?> watchOrder(String id);

  // Commands (writes synchronously to server, then UI updates via streams)
  Future<Result<AppError, Order>> createOrder(CustomerOrderInput input);
  
  // No direct refresh methods needed, handled by SessionManager
}
