import 'package:dispatcher/src/domain/entities/dispatcher_sync.dart';

import 'package:dispatcher/src/features/orders/data/dtos/dispatcher_metrics_dto.dart';
import 'package:shared/shared.dart';

class DispatcherSyncDto {
  const DispatcherSyncDto({
    required this.orders,
    required this.riders,
    required this.lastUpdated,
    this.metrics,
    this.deletedOrderIds = const [],
    this.deletedRiderIds = const [],
  });

  factory DispatcherSyncDto.fromJson(Map<String, dynamic> json) {
    return DispatcherSyncDto(
      orders: (json['orders'] as List<dynamic>?)
              ?.map((e) => OrderDto.fromJson(e as Map<String, dynamic>))
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
      deletedOrderIds: (json['deletedOrderIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      deletedRiderIds: (json['deletedRiderIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  final List<OrderDto> orders;
  final List<RiderDto> riders;
  final int lastUpdated;
  final DispatcherMetricsDto? metrics;
  final List<String> deletedOrderIds;
  final List<String> deletedRiderIds;

  Map<String, dynamic> toJson() {
    return {
      'orders': orders.map((e) => e.toJson()).toList(),
      'riders': riders.map((e) => e.toJson()).toList(),
      'lastUpdated': lastUpdated,
      'metrics': metrics?.toJson(),
      'deletedOrderIds': deletedOrderIds,
      'deletedRiderIds': deletedRiderIds,
    };
  }

  DispatcherSync toEntity() => DispatcherSync(
        orders: orders.map((e) => e.toEntity()).toList(),
        riders: riders.map((e) => e.toEntity()).toList(),
        metrics: metrics,
        deletedOrderIds: deletedOrderIds,
        deletedRiderIds: deletedRiderIds,
        lastUpdated: DateTime.fromMillisecondsSinceEpoch(lastUpdated),
      );
}
