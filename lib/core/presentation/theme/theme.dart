import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logistix/core/presentation/theme/colors.dart';

class MyTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primarySwatch: AppColors.orange,
    scaffoldBackgroundColor: AppColors.grey100,
    appBarTheme: const AppBarTheme(
      surfaceTintColor: AppColors.blueGrey,
      color: AppColors.grey100,
      centerTitle: false,
    ),
    colorScheme: const ColorScheme.light(
      primary: AppColors.orange,
      secondary: AppColors.blueGrey,
      tertiary: AppColors.redAccent,
      surface: Colors.white,
      onPrimary: AppColors.grey900,
      onSecondary: AppColors.grey900,
      onSurface: AppColors.grey900,
      primaryContainer: AppColors.blueGrey,
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      shadowColor: Colors.black54,
    ),
    tabBarTheme: const TabBarThemeData(
      labelStyle: TextStyle(fontWeight: FontWeight.w600),
      unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500),
      dividerHeight: 0,
    ),
    dividerTheme: const DividerThemeData(color: AppColors.grey200),
    chipTheme: const ChipThemeData(
      side: BorderSide.none,
      padding: EdgeInsets.zero,
      labelStyle: TextStyle(
        color: Colors.black,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    ),
    textTheme: GoogleFonts.interTextTheme().apply(
      bodyColor: Colors.black87,
      displayColor: Colors.black.withAlpha(200),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      prefixIconColor: AppColors.blueGreyMaterial,
      hintStyle: TextStyle(color: Colors.grey),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: Color(0xFFE0E0E0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: AppColors.orange),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFFD50000), width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: Color(0xFFD50000), width: 1.5),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(6)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        backgroundColor: AppColors.blueGrey,
        foregroundColor: Colors.white,
      ),
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.grey100,
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Color(0xFF9E9E9E)),
        foregroundColor: AppColors.blueGrey,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(6)),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      elevation: 4,
      backgroundColor: Colors.white,
      shadowColor: Colors.black12,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.orange,
    ),
  );

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primarySwatch: AppColors.orange,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.orange,
      secondary: AppColors.blueGrey,
      tertiary: AppColors.redAccent,
      surface: Colors.black,
      onPrimary: AppColors.grey100,
      onSecondary: AppColors.grey200,
      onSurface: AppColors.grey200,
      primaryContainer: Colors.blueGrey,
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: AppColors.grey900,
      hintStyle: TextStyle(color: AppColors.grey700),
      prefixIconColor: Color(0xFFB0BEC5),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: AppColors.grey800),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: AppColors.orange),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFFD50000), width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: Color(0xFFD50000), width: 1.5),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(6)),
        ),
        foregroundColor: AppColors.grey100,
        backgroundColor: AppColors.blueGreyMaterial[900],
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppColors.grey800),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(6)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        foregroundColor: AppColors.grey100,
      ),
    ),
    dividerTheme: const DividerThemeData(color: AppColors.grey800),
    chipTheme: const ChipThemeData(
      side: BorderSide.none,
      padding: EdgeInsets.zero,
      labelStyle: TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    ),
    cardTheme: const CardThemeData(
      margin: EdgeInsets.zero,
      color: AppColors.grey900,
      shadowColor: AppColors.grey100,
    ),
    appBarTheme: const AppBarTheme(
      color: Colors.black,
      surfaceTintColor: AppColors.grey900,
      centerTitle: false,
    ),
    scaffoldBackgroundColor: Colors.black,
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.black,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      elevation: 4,
      backgroundColor: Colors.black,
      shadowColor: Colors.black54,
    ),
    textTheme: GoogleFonts.interTextTheme().apply(
      bodyColor: AppColors.grey200,
      displayColor: AppColors.grey200,
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.orange,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.orange,
    ),
  );
}
