import 'package:freezed_annotation/freezed_annotation.dart';

part 'dispatcher_metrics_dto.freezed.dart';
part 'dispatcher_metrics_dto.g.dart';

@freezed
abstract class DispatcherMetricsDto with _$DispatcherMetricsDto {
  const factory DispatcherMetricsDto({
    required int activeOrders,
    required int unassignedOrders,
    required int assignedOrders,
    required int enRouteOrders,
    required int onlineRidersCount,
    required int busyRidersCount,
  }) = _DispatcherMetricsDto;

  factory DispatcherMetricsDto.fromJson(Map<String, dynamic> json) =>
      _$DispatcherMetricsDtoFromJson(json);

  const DispatcherMetricsDto._();

  int get totalRiders => onlineRidersCount + busyRidersCount;
  int get activeRiders => busyRidersCount;
  int get availableRiders => onlineRidersCount;

  static Map<String, dynamic>? toJsonFunc(DispatcherMetricsDto? object) {
    return object?.toJson();
  }
}
