import 'package:dio/dio.dart';
import 'package:logistix/core/constants/objects.dart';
import 'package:logistix/core/env_config.dart';
import 'package:logistix/core/theme/styling.dart';
import 'package:logistix/core/utils/app_error.dart';
import 'package:logistix/core/utils/either.dart';
import 'package:logistix/core/utils/extensions/dio.dart';
import 'package:logistix/features/order_create/domain/repository/create_order_repo.dart';
import 'package:logistix/features/orders/domain/entities/create_order.dart';

class CreateOrderRepoImpl extends CreateOrderRepo {
  CreateOrderRepoImpl({required this.client});
  final Dio client;

  @override
  Future<Either<AppError, int>> createOrder(CreateOrderData data) async {
    final res = await client.post('/orders', data: data.toJson());
    return res.toAppErrorOr((res) {
      return res.data['ref_number'];
    });
  }

  @override
  Future<Either<AppError, String>> uploadImage(String path) async {
    await Future.delayed(duration_3s);
    return Either.success(
      '${EnvConfig.instance.apiUrl}/orders/images/${uuid.v1()}',
    );
  }

  // @override
  // Future<Either<AppError, String>> uploadImage(String path) async {
  //   final contentType = lookupMimeType(path)?.split('/');
  //   final formData = FormData.fromMap({
  //     'image_path': await MultipartFile.fromFile(
  //       path,
  //       contentType:
  //           contentType == null
  //               ? null
  //               : DioMediaType(contentType[0], contentType[1]),
  //     ),
  //   });
  //   final response = await client.post('orders/images', data: formData);
  //   return response.data['image_urls'];
  // }
}
