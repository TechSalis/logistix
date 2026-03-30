import 'package:dispatcher/src/domain/entities/dispatcher_sync.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shared/shared.dart';

part 'dispatcher_sync_dto.freezed.dart';
part 'dispatcher_sync_dto.g.dart';

@freezed
abstract class DispatcherSyncDto with _$DispatcherSyncDto {
  const factory DispatcherSyncDto({
    required List<OrderDto> orders,
    required List<RiderDto> riders,
    required DispatcherMetricsDto metrics,
    required int lastUpdated,
    @Default([]) List<String> deletedOrderIds,
    @Default([]) List<String> deletedRiderIds,
  }) = _DispatcherSyncDto;

  factory DispatcherSyncDto.fromJson(Map<String, dynamic> json) =>
      _$DispatcherSyncDtoFromJson(json);
}

extension DispatcherSyncDtoX on DispatcherSyncDto {
  DispatcherSync toEntity() => DispatcherSync(
    orders: orders.map((e) => e.toEntity()).toList(),
    riders: riders.map((e) => e.toEntity()).toList(),
    metrics: metrics,
    deletedOrderIds: deletedOrderIds,
    deletedRiderIds: deletedRiderIds,
    lastUpdated: DateTime.fromMillisecondsSinceEpoch(lastUpdated),
  );
}
