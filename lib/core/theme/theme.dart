import 'package:flutter/material.dart';
import 'package:logistix/core/theme/colors.dart';
import 'package:logistix/core/theme/styling.dart';

class MyTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primarySwatch: AppColors.orange,
    snackBarTheme: const SnackBarThemeData(
      showCloseIcon: true,
      backgroundColor: Colors.black,
    ),
    scaffoldBackgroundColor: AppColors.grey100,
    appBarTheme: const AppBarTheme(
      toolbarHeight: 40,
      centerTitle: false,
      color: AppColors.grey100,
      surfaceTintColor: AppColors.grey100,
      // titleTextStyle: TextStyle(
      //   color: AppColors.grey900,
      //   fontSize: 20,
      //   fontWeight: FontWeight.w500,
      // ),
    ),
    colorScheme: const ColorScheme.light(
      primary: AppColors.orange,
      secondary: AppColors.blueGrey,
      tertiary: AppColors.redAccent,
      surface: Colors.white,
      onPrimary: AppColors.grey800,
      onSecondary: AppColors.grey800,
      onSurface: AppColors.grey800,
      primaryContainer: AppColors.blueGrey,
    ),
    cardTheme: const CardThemeData(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius_12,
        side: BorderSide(color: AppColors.grey300),
      ),
      shadowColor: Colors.black38,
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
      // labelStyle: TextStyle(
      //   color: Colors.black,
      //   fontSize: 12,
      //   fontWeight: FontWeight.w500,
      // ),
    ),
    fontFamily: 'Inter',
    // textTheme: const TextTheme().apply(
    //   fontFamily: 'Inter',
    //   bodyColor: Colors.grey,
    //   displayColor: Colors.grey,
    // ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: Color(0xFFFAFAFA),
      prefixIconColor: AppColors.blueGreyMaterial,
      hintStyle: TextStyle(color: Colors.grey),
      contentPadding: padding_H16_V8,
      enabledBorder: OutlineInputBorder(
        borderRadius: borderRadius_12,
        borderSide: BorderSide(color: Color(0xFFE0E0E0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: borderRadius_12,
        borderSide: BorderSide(color: AppColors.orange),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFFD50000), width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: borderRadius_12,
        borderSide: BorderSide(color: Color(0xFFD50000), width: 1.5),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: roundRectBorder8,
        padding: padding_H16_V12,
        backgroundColor: AppColors.blueGrey,
        foregroundColor: AppColors.grey300,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Color(0xFF9E9E9E)),
        foregroundColor: AppColors.blueGrey,
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
      color: AppColors.orange,
    ),
  );

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primarySwatch: AppColors.orange,
    scaffoldBackgroundColor: Colors.black,
    snackBarTheme: const SnackBarThemeData(
      showCloseIcon: true,
      backgroundColor: AppColors.grey300,
    ),
    colorScheme: const ColorScheme.dark(
      primary: AppColors.orange,
      secondary: AppColors.blueGrey,
      tertiary: AppColors.redAccent,
      surface: Colors.black,
      onPrimary: AppColors.grey300,
      onSecondary: AppColors.grey300,
      onSurface: AppColors.grey300,
      primaryContainer: Colors.blueGrey,
    ),
    appBarTheme: const AppBarTheme(
      toolbarHeight: 40,
      centerTitle: false,
      color: Colors.black,
      surfaceTintColor: Colors.black,
    ),
    cardTheme: const CardThemeData(
      elevation: 1,
      margin: EdgeInsets.zero,
      color: AppColors.grey900,
      shadowColor: AppColors.grey300,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius_12,
        side: BorderSide(color: AppColors.grey800),
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: Colors.black,
      hintStyle: TextStyle(color: AppColors.grey700),
      prefixIconColor: Color.fromARGB(255, 100, 111, 114),
      contentPadding: padding_H16_V8,
      enabledBorder: OutlineInputBorder(
        borderRadius: borderRadius_12,
        borderSide: BorderSide(color: AppColors.grey800),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: borderRadius_12,
        borderSide: BorderSide(color: AppColors.orange),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFFD50000), width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: borderRadius_12,
        borderSide: BorderSide(color: Color(0xFFD50000), width: 1.5),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: roundRectBorder8,
        foregroundColor: AppColors.grey300,
        backgroundColor: AppColors.blueGreyMaterial[900],
        padding: padding_H16_V12,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppColors.grey800),
        shape: roundRectBorder8,
        padding: padding_H16_V12,
        foregroundColor: AppColors.grey300,
      ),
    ),
    dividerTheme: const DividerThemeData(color: AppColors.grey800),
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
      color: AppColors.orange,
    ),
  );
}
