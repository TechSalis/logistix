import 'package:flutter/material.dart';

abstract class LogistixRadii {
  // Border radius values
  static const double none = 0;
  static const double xs = 4;
  static const double sm = 6;
  static const double md = 8;
  static const double lg = 12;
  static const double xl = 16;
  static const double xxl = 24;
  static const double full = 9999;

  // Semantic radius
  static const double button = md;
  static const double input = md;
  static const double card = lg;
  static const double dialog = xl;
  static const double sheet = xxl;

  // BorderRadius constants
  static const BorderRadius borderRadiusXs = BorderRadius.all(
    Radius.circular(xs),
  );
  static const BorderRadius borderRadiusSm = BorderRadius.all(
    Radius.circular(sm),
  );
  static const BorderRadius borderRadiusMd = BorderRadius.all(
    Radius.circular(md),
  );
  static const BorderRadius borderRadiusLg = BorderRadius.all(
    Radius.circular(lg),
  );
  static const BorderRadius borderRadiusXl = BorderRadius.all(
    Radius.circular(xl),
  );
  static const BorderRadius borderRadiusXxl = BorderRadius.all(
    Radius.circular(xxl),
  );
  static const BorderRadius borderRadiusFull = BorderRadius.all(
    Radius.circular(full),
  );

  // Component-specific
  static const BorderRadius borderRadiusButton = borderRadiusMd;
  static const BorderRadius borderRadiusInput = borderRadiusMd;
  static const BorderRadius borderRadiusCard = borderRadiusLg;
  static const BorderRadius borderRadiusDialog = borderRadiusXl;
  static const BorderRadius borderRadiusSheet = borderRadiusXxl;
}
