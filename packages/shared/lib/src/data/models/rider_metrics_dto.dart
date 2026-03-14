import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shared/src/domain/entities/rider_metrics.dart';

part 'rider_metrics_dto.freezed.dart';
part 'rider_metrics_dto.g.dart';

@freezed
class RiderMetricsDto with _$RiderMetricsDto {
  const factory RiderMetricsDto({
    required int totalOrders,
    required int pendingOrders,
    required int inProgressOrders,
    required int deliveredOrders,
    required double codExpectedToday,
    required int onlineRiders,
    double? avgDeliveryTime,
  }) = _RiderMetricsDto;

  factory RiderMetricsDto.fromJson(Map<String, dynamic> json) =>
      _$RiderMetricsDtoFromJson(json);
}

extension RiderMetricsDtoX on RiderMetricsDto {
  RiderMetrics toEntity() {
    return RiderMetrics(
      totalOrders: totalOrders,
      pendingOrders: pendingOrders,
      inProgressOrders: inProgressOrders,
      deliveredOrders: deliveredOrders,
      codExpectedToday: codExpectedToday,
      onlineRiders: onlineRiders,
      avgDeliveryTime: avgDeliveryTime,
    );
  }
}
