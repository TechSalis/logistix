import 'package:rider/src/domain/entities/rider_sync.dart';
import 'package:rider/src/features/orders/data/dtos/rider_metrics_dto.dart';
import 'package:shared/shared.dart';

class RiderSyncDto {
  const RiderSyncDto({
    required this.orders,
    required this.rider,
    required this.lastUpdated,
    this.metrics,
    this.deletedOrderIds = const [],
  });

  factory RiderSyncDto.fromJson(Map<String, dynamic> json) {
    return RiderSyncDto(
      orders: (json['orders'] as List<dynamic>?)
              ?.map((e) => OrderDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      rider: RiderDto.fromJson(json['rider'] as Map<String, dynamic>),
      lastUpdated: json['lastUpdated'] as int? ?? 0,
      metrics: json['metrics'] != null
          ? RiderMetricsDto.fromJson(json['metrics'] as Map<String, dynamic>)
          : null,
      deletedOrderIds: (json['deletedOrderIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  final List<OrderDto> orders;
  final RiderDto rider;
  final int lastUpdated;
  final RiderMetricsDto? metrics;
  final List<String> deletedOrderIds;

  RiderSync toEntity() => RiderSync(
        orders: orders.map((e) => e.toEntity()).toList(),
        rider: rider.toEntity(),
        metrics: metrics,
        deletedOrderIds: deletedOrderIds,
        lastUpdated: DateTime.fromMillisecondsSinceEpoch(lastUpdated),
      );
}
