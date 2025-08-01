import 'package:dio/dio.dart';
import 'package:logistix/core/utils/app_error.dart';
import 'package:logistix/core/utils/either.dart';
import 'package:logistix/core/utils/extensions/dio.dart';
import 'package:logistix/core/utils/page.dart';
import 'package:logistix/features/orders/domain/entities/create_order.dart';
import 'package:logistix/features/orders/domain/entities/order_responses.dart';
import 'package:logistix/features/orders/domain/repository/orders_repository.dart';
import 'package:logistix/features/orders/infrastructure/models/order_repo_dtos.dart';

class OrdersRepositoryImpl extends OrdersRepository {
  OrdersRepositoryImpl({required this.client});
  final Dio client;

  @override
  Future<Either<AppError, void>> cancelOrder(String id) async {
    final res = await client.post('/orders/cancel/$id');
    return res.toAppErrorOr((res) {});
  }

  @override
  Future<Either<AppError, Iterable<Order>>> getMyOrders(
    PageData page,
    OrderFilter? filter,
  ) async {
    final res = await client.get(
      '/orders/my-orders',
      queryParameters: {...?filter?.toJson(), ...page.toJson()},
    );
    return res.toAppErrorOr((res) {
      return List.from(res.data).map((e) => OrderModel.fromJson(e));
    });
  }

  @override
  Future<Either<AppError, Order>> getOrder(String id) async {
    final res = await client.get('/orders/my-orders');
    return res.toAppErrorOr((res) => OrderModel.fromJson(res.data));
  }
}
