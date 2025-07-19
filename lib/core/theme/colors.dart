// File: app_colors.dart

import 'package:flutter/material.dart';

abstract class AppColors {
  static const greyMat = MaterialColor(0xFF8E827A, <int, Color>{
    50: Color(0xFFFAF8F7),
    100: Color(0xFFF2EEEB),
    200: Color(0xFFE1D8D3),
    300: Color(0xFFCFC1B9),
    400: Color(0xFFBFAEA4),
    500: Color(0xFF8E827A),
    600: Color(0xFF6E655F),
    700: Color(0xFF4F4844),
    800: Color(0xFF3B3632), // rich, dark mocha charcoal
    900: Color(0xFF252220), // warm charcoal black
  });

  static const redAccent = Color(0xFFC62828);
  static const blueGreyMat = Colors.blueGrey;
  static const orangeMat = MaterialColor(0xFFF97316, <int, Color>{
    50: Color(0xFFFFF7ED),
    100: Color(0xFFFFEDD5),
    200: Color(0xFFFED7AA),
    300: Color(0xFFFDBA74),
    400: Color(0xFFFB923C),
    500: Color(0xFFF97316),
    600: Color(0xFFEA580C),
    700: Color(0xFFC2410C),
    800: Color(0xFF9A3412),
    900: Color(0xFF7C2D12),
  });
}

class QuickActionColors {
  static const delivery = Color(0xFF64748B); // Calmer blue
  static const food = Color(0xFFF4511E); // Soft deep orange (food, spicy vibe)
  static const groceries = Color(0xFF43A047); // Balanced green
  static const errands = Color(0xFF8E24AA); // Royal purple – universal, classy
}
