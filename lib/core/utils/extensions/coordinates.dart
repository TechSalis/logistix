
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logistix/core/domain/entities/coordinate.dart';

extension PointToCoord on LatLng {
  Coordinates toCoordinates() {
    return Coordinates(latitude, longitude);
  }
}

extension PointFromCoord on Coordinates {
  LatLng toPoint() {
    return LatLng(latitude, longitude);
  }
}