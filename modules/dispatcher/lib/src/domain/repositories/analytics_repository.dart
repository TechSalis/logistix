import 'package:bootstrap/definitions/app_error.dart';
import 'package:bootstrap/definitions/result.dart';

abstract class AnalyticsRepository {
  Future<Result<AppError, String>> exportOrdersCsv({
    DateTime? startDate,
    DateTime? endDate,
    String? riderId,
  });

  Future<Result<AppError, String>> exportAnalyticsSummary({
    DateTime? startDate,
    DateTime? endDate,
  });
}
