import 'package:dio/dio.dart';

abstract class AppError {
  final String message;
  const AppError(this.message);

  @override
  String toString() => 'AppError($message)';
}

class NetworkError extends AppError {
  final int code;
  const NetworkError(super.message, {this.code = -1});

  factory NetworkError.fromResponse(Response res) {
    return NetworkError(
      res.data['messsage'] ?? res.data['error'] ?? 'Something went wrong',
      code: res.statusCode ?? -1,
    );
  }

  @override
  String toString() => 'NetworkError($message, code: $code)';
}

class BusinessError extends AppError {
  const BusinessError(super.message);

  @override
  String toString() => 'BusinessError($message)';
}
