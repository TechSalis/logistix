import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logistix/features/location_core/domain/entities/coordinate.dart';

extension ColorExt on Color {
  double toHue() => HSVColor.fromColor(this).hue;
}

extension ContextExtension on BuildContext {
  bool get isLightTheme => Theme.of(this).brightness == Brightness.light;
  bool get isDarkTheme => Theme.of(this).brightness == Brightness.dark;
}

extension PointFromCoord on Coordinates {
  LatLng toPoint() => LatLng(latitude, longitude);
}
