import 'package:rider/src/features/orders/data/dtos/rider_metrics_dto.dart';
import 'package:shared/shared.dart';

class RiderSync {
  const RiderSync({
    required this.orders,
    required this.rider,
    required this.lastUpdated,
    this.metrics,
    this.deletedOrderIds = const [],
  });

  final List<Order> orders;
  final Rider rider;
  final DateTime lastUpdated;
  final RiderMetricsDto? metrics;
  final List<String> deletedOrderIds;

  RiderSync copyWith({
    List<Order>? orders,
    Rider? rider,
    DateTime? lastUpdated,
    RiderMetricsDto? metrics,
    List<String>? deletedOrderIds,
  }) {
    return RiderSync(
      orders: orders ?? this.orders,
      rider: rider ?? this.rider,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      metrics: metrics ?? this.metrics,
      deletedOrderIds: deletedOrderIds ?? this.deletedOrderIds,
    );
  }
}
