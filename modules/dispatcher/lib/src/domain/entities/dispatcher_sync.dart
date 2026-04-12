import 'package:dispatcher/src/features/orders/data/dtos/dispatcher_metrics_dto.dart';
import 'package:shared/shared.dart';

class DispatcherSync {
  const DispatcherSync({
    required this.orders,
    required this.riders,
    required this.lastUpdated,
    this.metrics,
    this.deletedOrderIds = const [],
    this.deletedRiderIds = const [],
  });

  final List<Order> orders;
  final List<Rider> riders;
  final DateTime lastUpdated;
  final DispatcherMetricsDto? metrics;
  final List<String> deletedOrderIds;
  final List<String> deletedRiderIds;
}
