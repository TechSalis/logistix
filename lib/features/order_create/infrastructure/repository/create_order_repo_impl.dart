import 'dart:io';

import 'package:dio/dio.dart';
import 'package:logistix/core/services/dio_service.dart';
import 'package:logistix/core/utils/app_error.dart';
import 'package:logistix/core/utils/either.dart';
import 'package:logistix/features/auth/infrastructure/repository/auth_local_store.dart';
import 'package:logistix/features/order_create/domain/repository/create_order_repo.dart';
import 'package:logistix/features/order_create/entities/create_order.dart';

class CreateOrderRepoImpl extends CreateOrderRepo {
  CreateOrderRepoImpl({required this.client});
  final Dio client;

  @override
  Future<Either<AppError, int>> createOrder(CreateOrderData data) async {
    final res =
        await client.post('/orders', data: data.toJson()).handleDioException();
    return res.toAppErrorOr((res) => res.data['ref_number']);
  }

  @override
  Future<Either<AppError, String>> uploadImage(String path) async {
    final fileName = path.split('/').last;
    //TODO: move back to [client] before production
    final dio = Dio();
    final res =
        await dio
            .put(
              "http://127.0.0.1:8787/media/temp/orders",
              queryParameters: {'file_name': fileName},
              data: await File(path).readAsBytes(),
              options: Options(
                headers: {
                  'Content-Type': 'application/json',
                  HttpHeaders.authorizationHeader:
                      'Bearer ${AuthLocalStore.instance.getSession()?.token}',
                },
              ),
            )
            .handleDioException();

    final url = res.toAppErrorOr((res) => res.data['upload_url'] as String);
    dio.close(force: true);

    return url;
  }
}
