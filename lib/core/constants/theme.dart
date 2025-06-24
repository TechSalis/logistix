import 'package:flutter/material.dart';
import 'package:logistix/core/constants/colors.dart';

class MyTheme {
  static ThemeData get light => ThemeData(
    brightness: Brightness.light,
    primarySwatch: AppColors.orange,
    scaffoldBackgroundColor: Colors.grey[100],
    appBarTheme: const AppBarTheme(
      surfaceTintColor: Color(0xFF263238),
      color: Color(0xFFF5F5F5),
    ),
    colorScheme: const ColorScheme.light(
      primary: AppColors.orange,
      secondary: Color(0xFF263238),
      tertiary: AppColors.redAccent,
      primaryContainer: Color(0xFF263238),
      surface: Colors.white,
    ),
    dividerTheme: const DividerThemeData(color: Color(0xFFBDBDBD)),
    chipTheme: const ChipThemeData(selectedColor: AppColors.orange),
    textTheme: Typography.blackCupertino.apply(
      bodyColor: Colors.black87,
      displayColor: Colors.black87,
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: Color(0xFFEEEEEE),
      prefixIconColor: AppColors.blueGrey,
      hintStyle: TextStyle(color: Colors.grey),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        borderSide: BorderSide(color: Color(0xFFE0E0E0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        borderSide: BorderSide(color: AppColors.orange),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFFD50000), width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        borderSide: BorderSide(color: Color(0xFFD50000), width: 1.5),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        elevation: 2,
        backgroundColor: Colors.white,
        shadowColor: Colors.black54,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          side: BorderSide(color: Colors.black38),
        ),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        backgroundColor: AppColors.blueGrey[900],
        foregroundColor: Colors.white,
      ),
    ),
    cardTheme: const CardTheme(
      color: Color(0xFFFAFAFA),
      margin: EdgeInsets.zero,
      shadowColor: Colors.black87,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFFF5F5F5),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Color(0xFF9E9E9E)),
        foregroundColor: AppColors.redAccent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
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
    brightness: Brightness.dark,
    primarySwatch: AppColors.orange,
    colorScheme: ColorScheme.dark(
      primary: AppColors.orange,
      secondary: AppColors.blueGrey[900]!,
      tertiary: AppColors.redAccent,
      primaryContainer: Colors.blueGrey[900],
      surface: Colors.black,
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: Color(0xFF212121),
      hintStyle: TextStyle(color: Colors.grey),
      prefixIconColor: Color(0xFFB0BEC5),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        borderSide: BorderSide(color: Color(0xFF424242)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        borderSide: BorderSide(color: AppColors.orange),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFFD50000), width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        borderSide: BorderSide(color: Color(0xFFD50000), width: 1.5),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        // elevation: 2,
        backgroundColor: Colors.black,
        shadowColor: Colors.white54,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          side: BorderSide(color: Colors.black38),
        ),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        backgroundColor: AppColors.blueGrey[900],
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Color(0xFF424242)),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        foregroundColor: Colors.white,
      ),
    ),
    dividerTheme: DividerThemeData(color: Colors.grey[800]),
    chipTheme: const ChipThemeData(selectedColor: AppColors.orange),
    cardTheme: CardTheme(
      color: Colors.black87,
      shadowColor: Colors.grey[400],
      margin: EdgeInsets.zero,
    ),
    appBarTheme: const AppBarTheme(
      color: Color(0xFF151515),
      surfaceTintColor: Color(0xFF151515),
    ),
    scaffoldBackgroundColor: const Color(0xFF151515),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF191919),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      elevation: 4,
      backgroundColor: Colors.black,
      shadowColor: Colors.black54,
    ),
    textTheme: Typography.whiteCupertino.apply(
      bodyColor: Colors.grey[100],
      displayColor: Colors.grey[100],
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
