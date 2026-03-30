import 'package:freezed_annotation/freezed_annotation.dart';

part 'rider_metrics_dto.freezed.dart';
part 'rider_metrics_dto.g.dart';

@freezed
abstract class RiderMetricsDto with _$RiderMetricsDto {
  const factory RiderMetricsDto({
    required int totalOrders,
    required int pendingOrders,
    required int deliveredOrders,
  }) = _RiderMetricsDto;

  factory RiderMetricsDto.fromJson(Map<String, dynamic> json) =>
      _$RiderMetricsDtoFromJson(json);

  static Map<String, dynamic>? toJsonFunc(RiderMetricsDto? object) {
    return object?.toJson();
  }
}
