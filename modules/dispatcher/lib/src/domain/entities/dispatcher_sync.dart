import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shared/shared.dart';

part 'dispatcher_sync.freezed.dart';

@freezed
abstract class DispatcherSync with _$DispatcherSync {
  const factory DispatcherSync({
    required List<Order> orders,
    required List<Rider> riders,
    DispatcherMetricsDto? metrics,
    required DateTime lastUpdated,
    @Default([]) List<String> deletedOrderIds,
    @Default([]) List<String> deletedRiderIds,
  }) = _DispatcherSync;
}
