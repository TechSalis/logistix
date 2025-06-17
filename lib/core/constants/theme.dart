import 'package:flutter/material.dart';
import 'package:logistix/core/constants/colors.dart';

class MyTheme {
  static ThemeData get light => ThemeData(
    brightness: Brightness.light,
    primarySwatch: AppColors.primarySwatch,
    scaffoldBackgroundColor: Colors.white,
    colorScheme: ColorScheme.light(
      primary: AppColors.primarySwatch,
      secondary: AppColors.blueGrey,
      surface: Colors.white,
    ),
    // cardColor: Colors.white,
    chipTheme: ChipThemeData(selectedColor: AppColors.primarySwatch),
    // appBarTheme: AppBarTheme(
    //   elevation: 1,
    //   backgroundColor: Colors.white,
    //   foregroundColor: Colors.black87,
    //   iconTheme: IconThemeData(color: Colors.black87),
    // ),
    // textTheme: Typography.blackCupertino.copyWith(
    //   bodyMedium: TextStyle(color: Colors.black87),
    // ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey[100],
      prefixIconColor: AppColors.blueGrey,
      hintStyle: TextStyle(color: Colors.grey),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
        borderSide: BorderSide(color: Colors.red[700]!, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.red[700]!, width: 1.5),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: AppColors.blueGrey),
        ),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        backgroundColor: AppColors.blueGrey[900],
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
    cardTheme: CardTheme(color: Colors.grey[200]),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.grey[200],
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      elevation: 8,
      backgroundColor: Colors.white,
      shadowColor: Colors.black12,
    ),
  );

  static ThemeData get dark => ThemeData(
    brightness: Brightness.dark,
    primarySwatch: AppColors.primarySwatch,
    scaffoldBackgroundColor: Colors.grey[900],
    colorScheme: ColorScheme.dark(
      primary: AppColors.primarySwatch,
      secondary: AppColors.blueGrey,
      surface: Colors.black,
    ),
    chipTheme: ChipThemeData(selectedColor: AppColors.primarySwatch),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey[850],
      hintStyle: TextStyle(color: Colors.grey),
      prefixIconColor: AppColors.blueGrey[200],
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey[700]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey[700]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppColors.primarySwatch),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red[700]!, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.red[700]!, width: 1.5),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: AppColors.blueGrey),
        ),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        backgroundColor: AppColors.blueGrey[900],
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.grey[900],
    ),
    cardTheme: CardTheme(color: Colors.grey[900]),
    bottomSheetTheme: BottomSheetThemeData(
      elevation: 8,
      backgroundColor: Colors.black,
      shadowColor: Colors.black54,
    ),
  );
}
