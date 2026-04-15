import 'package:dispatcher/src/features/orders/data/dtos/dispatcher_metrics_dto.dart';

// ignore: one_member_abstracts
abstract class MetricsRepository {
  Stream<DispatcherMetricsDto?> watchMetrics();
}
