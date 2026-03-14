import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared/shared.dart';

part 'rider_state.freezed.dart';

@freezed
class RiderState with _$RiderState {
  const factory RiderState.initial() = _Initial;
  const factory RiderState.loading() = _Loading;
  const factory RiderState.loaded(
    Rider rider, {
    @Default([]) List<Order> orders,
    @Default(false) bool isRefreshing,
    @Default(false) bool isOrdersLoading,
    Position? location,
  }) = _Loaded;
  const factory RiderState.error(String message) = _Error;
}
