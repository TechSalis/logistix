import 'package:logistix/core/utils/app_error.dart';
import 'package:logistix/core/utils/either.dart';
import 'package:logistix/features/orders/domain/entities/create_order.dart';

abstract class CreateOrderRepo {
  Future<Either<AppError, int>> createOrder(CreateOrderData data);
}
