// File: app_colors.dart

import 'package:flutter/material.dart';

abstract class AppColors {
  static const redAccent = Colors.redAccent;
  static const blueGreyMaterial = Colors.blueGrey;
  static const blueGrey = Color(0xFF263238);
  static const grey100 = Color(0xFFF5F5F5);
  static const grey200 = Color(0xFFEEEEEE);
  static const grey300 = Color(0xFFE0E0E0);
  static const grey700 = Color(0xFF616161);
  static const grey800 = Color(0xFF424242);
  static const grey900 = Color.fromARGB(255, 25, 25, 25);

  static const orange = MaterialColor(
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
  static const delivery = Color(0xFF64748B); // Calmer blue
  static const food = Color(0xFFF4511E); // Soft deep orange (food, spicy vibe)
  static const groceries = Color(0xFF43A047); // Balanced green
  static const errands = Color(0xFF8E24AA); // Royal purple – universal, classy
}
