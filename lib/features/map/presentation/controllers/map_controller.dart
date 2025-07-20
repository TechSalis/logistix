import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:logistix/features/location_core/domain/entities/coordinate.dart';

class MyMapController {
  final controller = MapController();

  /// Center the map on the given coordinates with animation.
  void animateTo(Coordinates latLng, {Duration? duration}) {
    controller.move(latLng.toPoint(), controller.camera.zoom, id: 'animate');
  }

  /// Instantly set the position (no animation)
  void setPosition(Coordinates latLng, {double zoom = 15.0}) {
    controller.move(latLng.toPoint(), zoom);
  }

  Coordinates getCoordinates() => controller.camera.center.toCoords();

  void dispose() => controller.dispose();
}

extension PointFromCoord on Coordinates {
  LatLng toPoint() => LatLng(latitude, longitude);
}
extension CoordFromPoint on LatLng {
  Coordinates toCoords() => Coordinates(latitude, longitude);
}
