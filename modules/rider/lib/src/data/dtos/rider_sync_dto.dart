import 'package:rider/src/domain/entities/rider_sync.dart';
import 'package:rider/src/features/deliveries/data/dtos/rider_metrics_dto.dart';
import 'package:shared/shared.dart';

class RiderSyncDto {
  const RiderSyncDto({
    required this.deliveries,
    required this.rider,
    required this.lastUpdated,
    this.metrics,
    this.deletedDeliveryIds = const [],
  });

  factory RiderSyncDto.fromJson(Map<String, dynamic> json) {
    return RiderSyncDto(
      deliveries: (json['deliveries'] as List<dynamic>?)
              ?.map((e) => DeliveryDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      rider: RiderDto.fromJson(json['rider'] as Map<String, dynamic>),
      lastUpdated: json['lastUpdated'] as int? ?? 0,
      metrics: json['metrics'] != null
          ? RiderMetricsDto.fromJson(json['metrics'] as Map<String, dynamic>)
          : null,
      deletedDeliveryIds: (json['deletedDeliveryIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  final List<DeliveryDto> deliveries;
  final RiderDto rider;
  final int lastUpdated;
  final RiderMetricsDto? metrics;
  final List<String> deletedDeliveryIds;

  RiderSync toEntity() => RiderSync(
        deliveries: deliveries.map((e) => e.toEntity()).toList(),
        rider: rider.toEntity(),
        metrics: metrics,
        deletedDeliveryIds: deletedDeliveryIds,
        lastUpdated: DateTime.fromMillisecondsSinceEpoch(lastUpdated),
      );
}
