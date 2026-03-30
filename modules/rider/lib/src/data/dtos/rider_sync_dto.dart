import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:rider/src/domain/entities/rider_sync.dart';
import 'package:shared/shared.dart';

part 'rider_sync_dto.freezed.dart';
part 'rider_sync_dto.g.dart';

@freezed
abstract class RiderSyncDto with _$RiderSyncDto {
  const factory RiderSyncDto({
    required List<OrderDto> orders,
    required RiderDto rider,
    required RiderMetricsDto metrics,
    required int lastUpdated,
    @Default([]) List<String> deletedOrderIds,
  }) = _RiderSyncDto;

  const RiderSyncDto._();

  factory RiderSyncDto.fromJson(Map<String, dynamic> json) =>
      _$RiderSyncDtoFromJson(json);

  RiderSync toEntity() => RiderSync(
    orders: orders.map((e) => e.toEntity()).toList(),
    rider: rider.toEntity(),
    metrics: metrics,
    deletedOrderIds: deletedOrderIds,
    lastUpdated: DateTime.fromMillisecondsSinceEpoch(lastUpdated),
  );
}
