import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:geolocator/geolocator.dart';

part 'map_state.freezed.dart';

@freezed
class MapState with _$MapState {
  const factory MapState.initial() = _Initial;

  const factory MapState.checkingPermission() = _CheckingPermission;

  const factory MapState.permissionDenied({
    required String message,
  }) = _PermissionDenied;

  const factory MapState.ready({
    required Position currentPosition,
  }) = _Ready;
}
