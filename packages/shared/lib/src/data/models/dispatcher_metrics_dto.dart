import 'package:drift/drift.dart' hide Column, JsonKey;
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shared/src/data/local/database.dart';

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

  DispatcherMetricsCompanion toDriftCompanion(String companyId) {
    return DispatcherMetricsCompanion(
      companyId: Value(companyId),
      activeOrders: Value(activeOrders),
      unassignedOrders: Value(unassignedOrders),
      assignedOrders: Value(assignedOrders),
      enRouteOrders: Value(enRouteOrders),
      onlineRidersCount: Value(onlineRidersCount),
      busyRidersCount: Value(busyRidersCount),
      updatedAt: Value(DateTime.now()),
    );
  }

  static Map<String, dynamic>? toJsonFunc(DispatcherMetricsDto? object) {
    return object?.toJson();
  }
}
