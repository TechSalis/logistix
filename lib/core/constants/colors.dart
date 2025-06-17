import 'package:flutter/material.dart';

abstract class AppColors {
  static const locationPin = Colors.redAccent;
  static const blueGrey = Colors.blueGrey;

  static const primarySwatch = MaterialColor(
    0xFFF97316,
    <int, Color>{
      50: Color(0xFFFFF7ED),
      100: Color(0xFFFFEDD5),
      200: Color(0xFFFED7AA),
      300: Color(0xFFFDBA74),
      400: Color(0xFFFB923C),
      500: Color(0xFFF97316), // Base
      600: Color(0xFFEA580C),
      700: Color(0xFFC2410C),
      800: Color(0xFF9A3412),
      900: Color(0xFF7C2D12),
    },
  );
}

class QuickActionColors {
  static const food = AppColors.primarySwatch;
  static const groceries = Color(0xFF22C55E);
  static const errands = Color(0xFF6366F1);
  static const lastDelivery = Color(0xFF64748B);
}
