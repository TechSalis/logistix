import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RiderMapUtils {
  static const riderHues = [
    BitmapDescriptor.hueRed,
    BitmapDescriptor.hueAzure,
    BitmapDescriptor.hueBlue,
    BitmapDescriptor.hueCyan,
    BitmapDescriptor.hueGreen,
    BitmapDescriptor.hueMagenta,
    BitmapDescriptor.hueOrange,
    BitmapDescriptor.hueRose,
    BitmapDescriptor.hueViolet,
    BitmapDescriptor.hueYellow,
  ];

  static double getHue(String id) {
    final index = id.hashCode.abs() % riderHues.length;
    return riderHues[index];
  }

  static Color getColor(String id) {
    final hue = getHue(id);
    return HSLColor.fromAHSL(1.0, hue, 0.7, 0.5).toColor();
  }
}
