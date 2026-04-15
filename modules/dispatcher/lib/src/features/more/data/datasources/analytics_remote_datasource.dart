import 'package:dio/dio.dart';
import 'package:dispatcher/src/features/more/data/dtos/analytics_export_request.dart';

// ignore: one_member_abstracts
abstract class AnalyticsRemoteDataSource {
  Future<String> exportAnalytics(AnalyticsExportRequest request);
}

class AnalyticsRemoteDataSourceImpl implements AnalyticsRemoteDataSource {
  AnalyticsRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<String> exportAnalytics(AnalyticsExportRequest request) async {
    final response = await _dio.get<String>(
      '/analytics/export',
      queryParameters: request.toJson(),
    );
    return response.data ?? '';
  }
}
