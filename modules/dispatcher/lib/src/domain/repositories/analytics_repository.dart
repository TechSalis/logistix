import 'package:bootstrap/definitions/app_error.dart';
import 'package:bootstrap/definitions/result.dart';

abstract class AnalyticsRepository {
  Future<Result<AppError, String>> exportAnalytics({
    DateTime? startDate,
    DateTime? endDate,
    String? riderId,
  });
}
