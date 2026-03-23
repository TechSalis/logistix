import 'dart:io';

import 'package:bootstrap/definitions/app_error.dart';
import 'package:bootstrap/interfaces/http/token_store.dart';
import 'package:http/http.dart' as http;
import 'package:shared/shared.dart';

abstract class AnalyticsRemoteDataSource {
  Future<String> exportOrdersCsv({
    DateTime? startDate,
    DateTime? endDate,
    String? riderId,
  });

  Future<String> exportAnalyticsSummary({
    DateTime? startDate,
    DateTime? endDate,
  });
}

class AnalyticsRemoteDataSourceImpl implements AnalyticsRemoteDataSource {
  AnalyticsRemoteDataSourceImpl(this.tokenStore);
  final TokenStore tokenStore;

  @override
  Future<String> exportOrdersCsv({
    DateTime? startDate,
    DateTime? endDate,
    String? riderId,
  }) async {
    return _exportFromPath(
      '/analytics/export/orders',
      startDate: startDate,
      endDate: endDate,
      riderId: riderId,
    );
  }

  @override
  Future<String> exportAnalyticsSummary({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return _exportFromPath(
      '/analytics/export/summary',
      startDate: startDate,
      endDate: endDate,
    );
  }

  Future<String> _exportFromPath(
    String path, {
    DateTime? startDate,
    DateTime? endDate,
    String? riderId,
  }) async {
    final tokenObj = await tokenStore.read();
    final token = tokenObj?.authorization;

    if (token == null) {
      throw const AppError(message: 'Authentication token not found');
    }

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

    final uri = Uri.parse(
      '${EnvConfig.apiUrl}$path',
    ).replace(queryParameters: queryParams);

    try {
      final response = await http
          .get(
            uri,
            headers: {
              HttpHeaders.authorizationHeader: token,
              HttpHeaders.acceptHeader: 'text/csv',
            },
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw AppError(
          message: 'Export failed with status ${response.statusCode}',
          error: response.body,
        );
      }
    } catch (e) {
      if (e is AppError) rethrow;
      throw AppError(message: 'Export failed', error: e);
    }
  }
}
