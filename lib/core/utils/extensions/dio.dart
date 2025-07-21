import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

extension DioExtension on Ref {
  Dio autoDisposeDio() {
    final dio = Dio();
    onDispose(() => dio.close(force: true));
    return dio;
  }
}
