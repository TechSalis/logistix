import 'package:dispatcher/src/features/orders/data/dtos/dispatcher_metrics_dto.dart';

abstract class MetricsRepository {
  Stream<DispatcherMetricsDto?> watchMetrics();
}
