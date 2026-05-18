import 'package:dispatcher/src/features/deliveries/data/dtos/dispatcher_metrics_dto.dart';
import 'package:shared/shared.dart';

class DispatcherSync {
  const DispatcherSync({
    required this.deliveries,
    required this.riders,
    required this.lastUpdated,
    this.metrics,
    this.deletedDeliveryIds = const [],
    this.deletedRiderIds = const [],
  });

  final List<Delivery> deliveries;
  final List<Rider> riders;
  final DateTime lastUpdated;
  final DispatcherMetricsDto? metrics;
  final List<String> deletedDeliveryIds;
  final List<String> deletedRiderIds;
}
