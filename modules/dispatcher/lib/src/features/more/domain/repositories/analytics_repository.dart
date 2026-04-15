import 'package:bootstrap/definitions/app_error.dart';
import 'package:bootstrap/definitions/result.dart';
import 'package:shared/shared.dart';

// ignore: one_member_abstracts
abstract class AnalyticsRepository {
  Future<Result<AppError, String>> exportAnalytics({
    DateTime? startDate,
    DateTime? endDate,
    String? riderId,
    List<OrderStatus>? statuses,
  });
}
