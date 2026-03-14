import 'package:bootstrap/definitions/app_error.dart';
import 'package:bootstrap/definitions/result.dart';
import 'package:shared/shared.dart';

abstract class MetricsRepository {
  Future<Result<AppError, Metrics>> getMetrics();
}
