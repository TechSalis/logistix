import 'package:flutter/material.dart';

extension ContextExtension on BuildContext {
  bool get isLightTheme => Theme.of(this).brightness == Brightness.light;
  bool get isDarkTheme => Theme.of(this).brightness == Brightness.dark;
}
