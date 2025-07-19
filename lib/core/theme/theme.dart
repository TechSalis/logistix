import 'package:flutter/material.dart';
import 'package:logistix/core/theme/colors.dart';
import 'package:logistix/core/theme/styling.dart';

class MyTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primarySwatch: AppColors.orangeMat,
    snackBarTheme: const SnackBarThemeData(
      showCloseIcon: true,
      backgroundColor: Colors.black,
    ),
    scaffoldBackgroundColor: AppColors.greyMat.shade50,
    appBarTheme: AppBarTheme(
      toolbarHeight: 48,
      centerTitle: false,
      color: AppColors.greyMat.shade50,
      surfaceTintColor: AppColors.greyMat.shade100,
      titleTextStyle: const TextStyle(
        color: Colors.black,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    colorScheme: ColorScheme.light(
      primary: AppColors.orangeMat,
      secondary: AppColors.blueGreyMat.shade900,
      tertiary: AppColors.redAccent,
      surface: Colors.white,
      onPrimary: AppColors.greyMat.shade800,
      onSecondary: AppColors.greyMat.shade800,
      onSurface: AppColors.greyMat.shade800,
      primaryContainer: AppColors.blueGreyMat,
    ),
    cardTheme: CardThemeData(
      elevation: 1,
      margin: EdgeInsets.zero,
      shadowColor: Colors.black38,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius_12,
        side: BorderSide(color: AppColors.greyMat.shade300),
      ),
    ),
    tabBarTheme: const TabBarThemeData(
      labelStyle: TextStyle(fontWeight: FontWeight.w600),
      unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500),
      dividerHeight: 0,
    ),
    dividerTheme: DividerThemeData(color: AppColors.greyMat.shade200),
    chipTheme: const ChipThemeData(
      side: BorderSide.none,
      padding: EdgeInsets.zero,
    ),
    fontFamily: 'Inter',
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      prefixIconColor: AppColors.blueGreyMat.shade400,
      hintStyle: const TextStyle(color: Colors.grey),
      contentPadding: padding_H16_V8,
      enabledBorder: const OutlineInputBorder(
        borderRadius: borderRadius_12,
        borderSide: BorderSide(color: Color(0xFFE0E0E0)),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: borderRadius_12,
        borderSide: BorderSide(color: AppColors.orangeMat),
      ),
      errorBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFFD50000), width: 1),
      ),
      focusedErrorBorder: const OutlineInputBorder(
        borderRadius: borderRadius_12,
        borderSide: BorderSide(color: Color(0xFFD50000), width: 1.5),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 4,
        shape: roundRectBorder8,
        padding: padding_H16_V12,
        backgroundColor: AppColors.blueGreyMat.shade900,
        foregroundColor: Colors.white,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Color(0xFF9E9E9E)),
        foregroundColor: AppColors.blueGreyMat,
        padding: padding_H16_V12,
        shape: roundRectBorder8,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        padding: padding_H16_V12,
        textStyle: const TextStyle(fontSize: 15),
        shape: roundRectBorder8,
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      elevation: 4,
      backgroundColor: Colors.white,
      shadowColor: Colors.black12,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.orangeMat,
    ),
  );

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primarySwatch: AppColors.orangeMat,
    scaffoldBackgroundColor: Colors.black,
    snackBarTheme: SnackBarThemeData(
      showCloseIcon: true,
      backgroundColor: AppColors.greyMat.shade300,
    ),
    dialogTheme: DialogThemeData(
      barrierColor: AppColors.greyMat.shade900.withAlpha(150),
    ),
    colorScheme: ColorScheme.dark(
      primary: AppColors.orangeMat,
      secondary: AppColors.blueGreyMat,
      tertiary: AppColors.redAccent,
      surface: Colors.black,
      onPrimary: AppColors.greyMat.shade300,
      onSecondary: AppColors.greyMat.shade300,
      onSurface: AppColors.greyMat.shade300,
      primaryContainer: Colors.blueGrey,
    ),
    appBarTheme: const AppBarTheme(
      toolbarHeight: 48,
      centerTitle: false,
      color: Colors.black,
      surfaceTintColor: Colors.black,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 1,
      margin: EdgeInsets.zero,
      color: AppColors.greyMat.shade900,
      shadowColor: AppColors.greyMat.shade700,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius_12,
        side: BorderSide(color: AppColors.greyMat.shade800),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.black,
      hintStyle: TextStyle(color: AppColors.greyMat.shade700),
      prefixIconColor: const Color(0xFF646F72),
      contentPadding: padding_H16_V8,
      enabledBorder: OutlineInputBorder(
        borderRadius: borderRadius_12,
        borderSide: BorderSide(color: AppColors.greyMat.shade800),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: borderRadius_12,
        borderSide: BorderSide(color: AppColors.orangeMat),
      ),
      errorBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFFD50000), width: 1),
      ),
      focusedErrorBorder: const OutlineInputBorder(
        borderRadius: borderRadius_12,
        borderSide: BorderSide(color: Color(0xFFD50000), width: 1.5),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 4,
        shape: roundRectBorder8,
        foregroundColor: AppColors.greyMat.shade300,
        backgroundColor: AppColors.blueGreyMat.shade900,
        padding: padding_H16_V12,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: AppColors.greyMat.shade800),
        shape: roundRectBorder8,
        padding: padding_H16_V12,
        foregroundColor: AppColors.greyMat.shade300,
      ),
    ),
    dividerTheme: DividerThemeData(color: AppColors.greyMat.shade800),
    chipTheme: const ChipThemeData(
      side: BorderSide.none,
      padding: EdgeInsets.zero,
    ),
    tabBarTheme: const TabBarThemeData(
      labelStyle: TextStyle(fontWeight: FontWeight.w600),
      unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500),
      dividerHeight: 0,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.black,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      elevation: 4,
      backgroundColor: Colors.black,
      shadowColor: Colors.black54,
    ),
    fontFamily: 'Inter',
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        textStyle: const TextStyle(fontSize: 15),
        padding: padding_H16_V12,
        shape: roundRectBorder8,
      ),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.orangeMat,
    ),
  );
}
