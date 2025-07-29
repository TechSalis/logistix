
import 'package:dio/dio.dart';
import 'package:logistix/core/services/dio_service.dart';
import 'package:logistix/core/utils/app_error.dart';
import 'package:logistix/core/utils/either.dart';
import 'package:logistix/features/order_create/domain/repository/create_order_repo.dart';
import 'package:logistix/features/order_create/domain/entities/create_order.dart';
import 'package:logistix/features/order_create/infrastructure/dtos/create_order_dto.dart';

class CreateOrderRepoImpl extends CreateOrderRepo {
  CreateOrderRepoImpl({required this.client});
  final Dio client;

  @override
  Future<Either<AppError, CreateOrderResponse>> createOrder(
    CreateOrderData data,
  ) async {
    final res =
        await client.post('/orders', data: data.toJson()).handleDioException();
    return res.toAppErrorOr((res) => CreateOrderResponse.fromJson(res.data));
  }
}
