import 'package:geolocator/geolocator.dart';

abstract class MapState {
  const MapState();

  const factory MapState.initial() = MapStateInitial;
  const factory MapState.checkingPermission() = MapStateCheckingPermission;
  const factory MapState.permissionDenied({required String message}) = MapStatePermissionDenied;
  const factory MapState.ready({required Position currentPosition}) = MapStateReady;

  T? whenOrNull<T>({
    T Function()? initial,
    T Function()? checkingPermission,
    T Function(String message)? permissionDenied,
    T Function(Position currentPosition)? ready,
  }) {
    if (this is MapStateInitial) return initial?.call();
    if (this is MapStateCheckingPermission) return checkingPermission?.call();
    if (this is MapStatePermissionDenied) return permissionDenied?.call((this as MapStatePermissionDenied).message);
    if (this is MapStateReady) return ready?.call((this as MapStateReady).currentPosition);
    return null;
  }
}

class MapStateInitial extends MapState {
  const MapStateInitial();
}

class MapStateCheckingPermission extends MapState {
  const MapStateCheckingPermission();
}

class MapStatePermissionDenied extends MapState {
  const MapStatePermissionDenied({required this.message});
  final String message;
}

class MapStateReady extends MapState {
  const MapStateReady({required this.currentPosition});
  final Position currentPosition;
}
