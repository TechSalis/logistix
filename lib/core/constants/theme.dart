import 'package:flutter/material.dart';
import 'package:logistix/core/constants/colors.dart';

class MyTheme {
  static ThemeData get light => ThemeData(
    brightness: Brightness.light,
    primarySwatch: AppColors.primarySwatch,
    scaffoldBackgroundColor: Colors.white,
    colorScheme: ColorScheme.light(
      primary: AppColors.primarySwatch,
      secondary: AppColors.blueGrey[900]!,
      tertiary: AppColors.redAccent,
      surface: Colors.white,
    ),
    dividerTheme: DividerThemeData(color: Colors.grey[300]),
    // cardColor: Colors.white,
    chipTheme: ChipThemeData(selectedColor: AppColors.primarySwatch),
    textTheme: Typography.blackCupertino.copyWith(
      bodyMedium: TextStyle(color: Colors.black87),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey[100],
      prefixIconColor: AppColors.blueGrey,
      hintStyle: TextStyle(color: Colors.grey),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppColors.primarySwatch),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.redAccent[700]!, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.redAccent[700]!, width: 1.5),
      ),
    ),

    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        elevation: 4,
        backgroundColor: Colors.white,
        shadowColor: Colors.black45,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Colors.black12),
        ),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        backgroundColor: AppColors.blueGrey[900],
        foregroundColor: Colors.white,
      ),
    ),
    cardTheme: CardTheme(color: Colors.grey[50]),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.grey[200],
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: Colors.grey[500]!),
        foregroundColor: AppColors.redAccent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),

    bottomSheetTheme: BottomSheetThemeData(
      elevation: 8,
      backgroundColor: Colors.white,
      shadowColor: Colors.black12,
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: AppColors.primarySwatch,
    ),
  );

  static ThemeData get dark => ThemeData(
    brightness: Brightness.dark,
    primarySwatch: AppColors.primarySwatch,
    // scaffoldBackgroundColor: Colors.grey[900],
    colorScheme: ColorScheme.dark(
      primary: AppColors.blueGrey[900]!,
      secondary: AppColors.primarySwatch,
      tertiary: AppColors.redAccent,
      surface: Colors.black,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey.shade900,
      hintStyle: TextStyle(color: Colors.grey),
      prefixIconColor: AppColors.blueGrey[200],
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey[800]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey[800]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppColors.primarySwatch),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.redAccent[700]!, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.redAccent[700]!, width: 1.5),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        elevation: 2,
        backgroundColor: Colors.black,
        shadowColor: Colors.white54,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Colors.black38),
        ),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        backgroundColor: AppColors.blueGrey[900],
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: Colors.grey[800]!),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        foregroundColor: Colors.white,
      ),
    ),
    dividerTheme: DividerThemeData(color: Colors.grey[800]),
    chipTheme: ChipThemeData(selectedColor: AppColors.primarySwatch),
    cardTheme: CardTheme(color: Colors.black87, shadowColor: Colors.grey[400]),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.grey[900],
    ),
    bottomSheetTheme: BottomSheetThemeData(
      elevation: 8,
      backgroundColor: Colors.black,
      shadowColor: Colors.black54,
    ),
    textTheme: Typography.whiteCupertino.copyWith(
      bodyMedium: TextStyle(color: Colors.white70),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primarySwatch,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: AppColors.primarySwatch,
    ),
  );
}
