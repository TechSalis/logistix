import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shared/shared.dart';

part 'rider_sync.freezed.dart';

@freezed
abstract class RiderSync with _$RiderSync {
  const factory RiderSync({
    required List<Order> orders,
    required Rider rider,
    required DateTime lastUpdated,
    RiderMetricsDto? metrics,
    @Default([]) List<String> deletedOrderIds,
  }) = _RiderSync;
}
