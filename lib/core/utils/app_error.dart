import 'package:dio/dio.dart';

abstract class AppError {
  final String message;
  const AppError(this.message);

  @override
  String toString() => 'AppError($message)';
}

class NetworkError extends AppError {
  final int? statusCode;
  final DioExceptionType? type;

  const NetworkError(super.message, {this.statusCode, this.type});

  factory NetworkError.fromResponse(Response res) {
    return NetworkError(
      res.data['messsage'] ?? res.data['error'] ?? 'Something went wrong',
      statusCode: res.statusCode ?? -1,
    );
  }
  @override
  String toString() =>
      'NetworkError: ($message (statusCode: $statusCode, type: $type))';
}

class BusinessError extends AppError {
  const BusinessError(super.message);

  @override
  String toString() => 'BusinessError($message)';
}
