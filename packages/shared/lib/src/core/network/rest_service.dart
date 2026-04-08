import 'package:bootstrap/interfaces/logger/logger.dart';
import 'package:dio/dio.dart';

class RestService {
  RestService({
    required Dio client,
    Logger? logger,
  }) : _client = client,
       _logger = logger;

  final Dio _client;
  final Logger? _logger;

  Future<Response<T>> post<T>(String path, {Object? body}) async {
    _logger?.debug('REST POST: $path', extra: {'body': body});

    try {
      final response = await _client.post<T>(
        path,
        data: body,
      );
      return response;
    } on DioException catch (e) {
      _logger?.error(
        'REST POST error on $path: ${e.message}',
        extra: {
          'response': e.response?.data,
          'status': e.response?.statusCode,
        },
      );
      rethrow;
    }
  }

  Future<Response<T>> get<T>(String path, {Map<String, dynamic>? queryParams}) async {
    _logger?.debug('REST GET: $path');

    try {
      final response = await _client.get<T>(
        path,
        queryParameters: queryParams,
      );
      return response;
    } on DioException catch (e) {
      _logger?.error(
        'REST GET error on $path: ${e.message}',
        extra: {
          'response': e.response?.data,
          'status': e.response?.statusCode,
        },
      );
      rethrow;
    }
  }
}
