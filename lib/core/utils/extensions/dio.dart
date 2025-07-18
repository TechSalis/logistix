import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logistix/core/utils/app_error.dart';
import 'package:logistix/core/utils/either.dart';

extension DioExt on Response {
  bool isSuccess() {
    return statusCode != null && statusCode! >= 200 && statusCode! < 300;
  }

  Either<AppError, T> toAppErrorOr<T>(T Function(Response res) response) {
    try {
      if (isSuccess()) return Either.success(response(this));
      return Either.fail(NetworkError.fromResponse(this));
    } catch (e) {
      return Either.fail(BusinessError(e.toString()));
    }
  }
}

extension DioExtension on Ref {
  Dio autoDisposeDio() {
    final dio = Dio();
    onDispose(() => dio.close(force: true));
    return dio;
  }
}
