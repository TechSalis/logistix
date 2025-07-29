import 'package:logistix/core/utils/app_error.dart';
import 'package:logistix/core/utils/either.dart';
import 'package:logistix/features/order_create/domain/entities/create_order.dart';
import 'package:logistix/features/order_create/infrastructure/dtos/create_order_dto.dart';

abstract class CreateOrderRepo {
  Future<Either<AppError, CreateOrderResponse>> createOrder(
    CreateOrderData data,
  );
}
