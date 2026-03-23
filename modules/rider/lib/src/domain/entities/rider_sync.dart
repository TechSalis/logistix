import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shared/shared.dart';

part 'rider_sync.freezed.dart';

@freezed
class RiderSync with _$RiderSync {
  const factory RiderSync({
    required List<Order> orders,
    required RiderMetricsDto metrics,
    required DateTime lastUpdated,
    @Default([]) List<String> deletedOrderIds,
  }) = _RiderSync;
}
