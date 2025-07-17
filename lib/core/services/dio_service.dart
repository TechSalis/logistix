import 'package:dio/dio.dart';
import 'package:logistix/core/env_config.dart';
import 'package:logistix/core/services/auth_store_service.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  static Dio get instance => _instance.dio;

  late final Dio dio;
  DioClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: EnvConfig.instance.apiUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        contentType: 'application/json',
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = (await AuthLocalStore.instance.getSession())?.token;
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );
  }
}
