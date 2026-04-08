import 'package:bootstrap/definitions/app_error.dart';
import 'package:shared/shared.dart';

abstract class AnalyticsRemoteDataSource {
  Future<String> exportAnalytics({
    DateTime? startDate,
    DateTime? endDate,
    String? riderId,
  });
}

class AnalyticsRemoteDataSourceImpl implements AnalyticsRemoteDataSource {
  AnalyticsRemoteDataSourceImpl(this._rest);
  final RestService _rest;

  @override
  Future<String> exportAnalytics({
    DateTime? startDate,
    DateTime? endDate,
    String? riderId,
  }) async {
    final queryParams = <String, String>{};
    if (startDate != null) {
      queryParams['startDate'] = startDate.toIso8601String();
    }
    if (endDate != null) {
      queryParams['endDate'] = endDate.toIso8601String();
    }
    if (riderId != null) {
      queryParams['riderId'] = riderId;
    }

    try {
      final response = await _rest.get<String>(
        '/analytics/export',
        queryParams: queryParams,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return response.data ?? '';
      } else {
        throw AppError(
          message: 'Export failed with status ${response.statusCode}',
          error: response.data.toString(),
        );
      }
    } catch (e) {
      if (e is AppError) rethrow;
      throw AppError(message: 'Export failed', error: e);
    }
  }
}
