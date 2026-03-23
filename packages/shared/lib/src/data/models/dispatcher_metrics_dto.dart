import 'package:freezed_annotation/freezed_annotation.dart';

part 'dispatcher_metrics_dto.freezed.dart';
part 'dispatcher_metrics_dto.g.dart';

@freezed
class DispatcherMetricsDto with _$DispatcherMetricsDto {
  const factory DispatcherMetricsDto({
    required int totalOrders,
    required int pendingOrders,
    required int deliveredOrders,
    required int totalRiders,
    required int activeRiders,
    required int availableRiders,
  }) = _DispatcherMetricsDto;

  factory DispatcherMetricsDto.fromJson(Map<String, dynamic> json) =>
      _$DispatcherMetricsDtoFromJson(json);

  static Map<String, dynamic>? toJsonFunc(DispatcherMetricsDto? object) {
    return object?.toJson();
  }
}
