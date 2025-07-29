import 'dart:io';

import 'package:dio/dio.dart';
import 'package:logistix/core/env_config.dart';
import 'package:logistix/core/services/dio_service.dart';
import 'package:logistix/core/utils/app_error.dart';
import 'package:logistix/core/utils/either.dart';
import 'package:logistix/features/order_create/domain/repository/upload_image_repo.dart';

class UploadImageRepoImpl extends UploadImageRepo {
  UploadImageRepoImpl({required this.client}) {
    client.options = BaseOptions(
      baseUrl: EnvConfig.instance.cloudflareUrl,
      headers: {'Content-Type': 'application/json'},
    );
    client.interceptors.add(LogInterceptor());
  }
  final Dio client;

  @override
  Future<Either<AppError, String>> uploadImage(String path) async {
    final fileName = path.split('/').last;
    final res =
        await client
            .put(
              "/media/temp/orders",
              queryParameters: {'file_name': fileName},
              data: await File(path).readAsBytes(),
            )
            .handleDioException();

    return res.toAppErrorOr((res) => res.data['upload_url'] as String);
  }
}
