import 'package:dispatcher/src/domain/entities/dispatcher_sync.dart';

import 'package:dispatcher/src/features/deliveries/data/dtos/dispatcher_metrics_dto.dart';
import 'package:shared/shared.dart';

class DispatcherSyncDto {
  const DispatcherSyncDto({
    required this.deliveries,
    required this.riders,
    required this.lastUpdated,
    this.metrics,
    this.deletedDeliveryIds = const [],
    this.deletedRiderIds = const [],
  });

  factory DispatcherSyncDto.fromJson(Map<String, dynamic> json) {
    return DispatcherSyncDto(
      deliveries: (json['deliveries'] as List<dynamic>?)
              ?.map((e) => DeliveryDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      riders: (json['riders'] as List<dynamic>?)
              ?.map((e) => RiderDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      lastUpdated: (json['lastUpdated'] as num).toInt(),
      metrics: json['metrics'] != null
          ? DispatcherMetricsDto.fromJson(json['metrics'] as Map<String, dynamic>)
          : null,
      deletedDeliveryIds: (json['deletedDeliveryIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      deletedRiderIds: (json['deletedRiderIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  final List<DeliveryDto> deliveries;
  final List<RiderDto> riders;
  final int lastUpdated;
  final DispatcherMetricsDto? metrics;
  final List<String> deletedDeliveryIds;
  final List<String> deletedRiderIds;

  Map<String, dynamic> toJson() {
    return {
      'deliveries': deliveries.map((e) => e.toJson()).toList(),
      'riders': riders.map((e) => e.toJson()).toList(),
      'lastUpdated': lastUpdated,
      'metrics': metrics?.toJson(),
      'deletedDeliveryIds': deletedDeliveryIds,
      'deletedRiderIds': deletedRiderIds,
    };
  }

  DispatcherSync toEntity() => DispatcherSync(
        deliveries: deliveries.map((e) => e.toEntity()).toList(),
        riders: riders.map((e) => e.toEntity()).toList(),
        metrics: metrics,
        deletedDeliveryIds: deletedDeliveryIds,
        deletedRiderIds: deletedRiderIds,
        lastUpdated: DateTime.fromMillisecondsSinceEpoch(lastUpdated),
      );
}
