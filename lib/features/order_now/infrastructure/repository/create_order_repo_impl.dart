import 'package:dio/dio.dart';
import 'package:logistix/core/utils/app_error.dart';
import 'package:logistix/core/utils/either.dart';
import 'package:logistix/core/utils/extensions/dio.dart';
import 'package:logistix/features/order_now/domain/repository/create_order_repo.dart';
import 'package:logistix/features/orders/domain/entities/create_order.dart';

class CreateOrderRepoImpl extends CreateOrderRepo {
  CreateOrderRepoImpl({required this.client});
  final Dio client;
  
  @override
  Future<Either<AppError, int>> createOrder(CreateOrderData data) async {
    final res = await client.post('/orders', data: data.toJson());
    return res.toAppErrorOr((res) => res.data['ref_number']);
  }
}
