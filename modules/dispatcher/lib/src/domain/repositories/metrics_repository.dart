import 'package:shared/shared.dart';

abstract class MetricsRepository {
  Stream<DispatcherMetricsDto?> watchMetrics();
}
