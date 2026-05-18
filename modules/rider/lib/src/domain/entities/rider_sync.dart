import 'package:rider/src/features/deliveries/data/dtos/rider_metrics_dto.dart';
import 'package:shared/shared.dart';

class RiderSync {
  const RiderSync({
    required this.deliveries,
    required this.rider,
    required this.lastUpdated,
    this.metrics,
    this.deletedDeliveryIds = const [],
  });

  final List<Delivery> deliveries;
  final Rider rider;
  final DateTime lastUpdated;
  final RiderMetricsDto? metrics;
  final List<String> deletedDeliveryIds;

  RiderSync copyWith({
    List<Delivery>? deliveries,
    Rider? rider,
    DateTime? lastUpdated,
    RiderMetricsDto? metrics,
    List<String>? deletedDeliveryIds,
  }) {
    return RiderSync(
      deliveries: deliveries ?? this.deliveries,
      rider: rider ?? this.rider,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      metrics: metrics ?? this.metrics,
      deletedDeliveryIds: deletedDeliveryIds ?? this.deletedDeliveryIds,
    );
  }
}
