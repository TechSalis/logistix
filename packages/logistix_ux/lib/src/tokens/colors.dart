import 'package:flutter/material.dart';

/// Premium color palette for Logistix
/// Inspired by modern logistics and enterprise SaaS applications
abstract class LogistixColors {
  // Primary - Deep Blue (professional, trustworthy)
  static const Color primary = Color(0xFF1E40AF); // blue-800
  static const Color primaryLight = Color(0xFF3B82F6); // blue-500
  static const Color primaryDark = Color(0xFF1E3A8A); // blue-900

  // Secondary - Indigo (complementary to the deep blue, modern)
  static const Color secondary = Color(0xFF6366F1); // indigo-500
  static const Color secondaryLight = Color(0xFF818CF8); // indigo-400
  static const Color secondaryDark = Color(0xFF4F46E5); // indigo-600

  // Neutrals - Slate (modern, clean)
  static const Color neutral100 = Color(0xFFF1F5F9);
  static const Color neutral200 = Color(0xFFE2E8F0);
  static const Color neutral800 = Color(0xFF1E293B);

  // Semantic
  static const Color success = Color(0xFF059669); // emerald-600
  static const Color warning = Color(0xFFF59E0B); // amber-500
  static const Color error = Color(0xFFDC2626); // red-600
  static const Color info = Color(0xFF0EA5E9); // sky-500

  // Surface
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDim = Color(0xFFF8FAFC);
  static const Color background = Color(0xFFF8FAFC);

  // Text
  static const Color text = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textTertiary = Color(0xFF94A3B8);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Border
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderStrong = Color(0xFFCBD5E1);

  // Common colors (replacing Flutter's Colors.*)
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Color(0x00000000);
  static const Color orange = Color(0xFFF97316); // orange-500 (consistent with warning tone)
  static const Color green = Color(0xFF10B981); // emerald-500 (consistent with success)
  static const Color grey = Color(0xFF6B7280); // gray-500
  static const Color amber = Color(0xFFFBBF24); // amber-400 (for ratings/stars)
}
