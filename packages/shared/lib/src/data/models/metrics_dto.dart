import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shared/src/domain/entities/metrics.dart';

part 'metrics_dto.freezed.dart';
part 'metrics_dto.g.dart';

@freezed
class MetricsDto with _$MetricsDto {
  const factory MetricsDto({
    required int totalOrders,
    required int pendingOrders,
    required int inProgressOrders,
    required int deliveredOrders,
    required double codExpectedToday,
    required int onlineRiders,
    double? avgDeliveryTime,
  }) = _MetricsDto;

  const MetricsDto._();

  factory MetricsDto.fromJson(Map<String, dynamic> json) =>
      _$MetricsDtoFromJson(json);

  Metrics toEntity() => Metrics(
    totalOrders: totalOrders,
    pendingOrders: pendingOrders,
    inProgressOrders: inProgressOrders,
    deliveredOrders: deliveredOrders,
    codExpectedToday: codExpectedToday,
    onlineRiders: onlineRiders,
    avgDeliveryTime: avgDeliveryTime,
  );
}
