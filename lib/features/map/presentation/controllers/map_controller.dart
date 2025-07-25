import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:latlong2/latlong.dart';
import 'package:logistix/features/location_core/domain/entities/coordinate.dart';

class MyMapController {
  MyMapController(TickerProvider vsync, {MapController? mapController})
    : controller = AnimatedMapController(
        vsync: vsync,
        mapController: mapController,
      );

  final AnimatedMapController controller;
  MapController get map => controller.mapController;

  /// Center the map on the given coordinates with animation.
  void animateTo(Coordinates coords, {Duration duration = Durations.medium4}) {
    controller.animateTo(
      dest: coords.toPoint(),
      curve: Curves.easeInOut,
      duration: duration,
    );
  }

  /// Instantly set the position (no animation)
  void setPosition(Coordinates latLng, {double zoom = 15.0}) {
    map.move(latLng.toPoint(), zoom);
  }

  Coordinates getCoordinates() => map.camera.center.toCoords();

  void dispose() => controller.dispose();
}

extension PointFromCoord on Coordinates {
  LatLng toPoint() => LatLng(latitude, longitude);
}

extension CoordFromPoint on LatLng {
  Coordinates toCoords() => Coordinates(latitude, longitude);
}
