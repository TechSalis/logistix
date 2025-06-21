import 'package:flutter/painting.dart';

extension ColorExt on Color {
  double toHue() {
    final hsvColor = HSVColor.fromColor(this);
    return hsvColor.hue;
  }
}
