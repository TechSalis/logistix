import 'package:logistix/core/utils/app_error.dart';
import 'package:logistix/core/utils/either.dart';
import 'package:logistix/core/utils/page.dart';
import 'package:logistix/features/orders/domain/entities/create_order.dart';
import 'package:logistix/features/orders/domain/entities/order_responses.dart';

abstract class OrdersRepository {
  Future<Either<AppError, Order>> getOrder(String id);
  Future<Either<AppError, void>> cancelOrder(String id);
  Future<Either<AppError, Iterable<Order>>> getMyOrders(
    PageData page,
    OrderFilter? filter,
  );
}
