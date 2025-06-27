import 'package:flutter/material.dart';
import 'package:logistix/core/constants/colors.dart';

class MyTheme {
  static ThemeData get light => ThemeData(
    brightness: Brightness.light,
    primarySwatch: AppColors.orange,
    scaffoldBackgroundColor: AppColors.grey100,
    appBarTheme: const AppBarTheme(
      surfaceTintColor: AppColors.blueGrey,
      color: AppColors.grey100,
    ),
    colorScheme: const ColorScheme.light(
      primary: AppColors.orange,
      secondary: AppColors.blueGrey,
      onSecondary: Colors.white,
      tertiary: AppColors.redAccent,
      primaryContainer: AppColors.blueGrey,
      surface: Colors.white,
    ),
    dividerTheme: const DividerThemeData(color: AppColors.grey200),
    chipTheme: const ChipThemeData(selectedColor: AppColors.orange),
    textTheme: Typography.blackCupertino.apply(
      bodyColor: Colors.black87,
      displayColor: Colors.black87,
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: Color(0xFFEEEEEE),
      prefixIconColor: AppColors.blueGreyMaterial,
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
    // iconButtonTheme: IconButtonThemeData(
    //   style: IconButton.styleFrom(
    //     elevation: 2,
    //     backgroundColor: Colors.white,
    //     padding: EdgeInsets.zero,
    //     // shadowColor: Colors.black54,
    //     // shape: const RoundedRectangleBorder(
    //     //   borderRadius: BorderRadius.all(Radius.circular(10)),
    //     //   side: BorderSide(color: Colors.black38),
    //     // ),
    //   ),
    // ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        backgroundColor: AppColors.blueGrey,
        foregroundColor: Colors.white,
      ),
    ),
    cardTheme: const CardThemeData(
      color: Color(0xFFFAFAFA),
      margin: EdgeInsets.zero,
      shadowColor: Colors.black87,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.grey100,
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Color(0xFF9E9E9E)),
        // foregroundColor: AppColors.redAccent,
        foregroundColor: AppColors.blueGrey,
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
    colorScheme: const ColorScheme.dark(
      primary: AppColors.orange,
      onPrimary: AppColors.grey100,
      secondary: AppColors.blueGrey,
      onSecondary: AppColors.grey200,
      tertiary: AppColors.redAccent,
      primaryContainer: Colors.blueGrey,
      surface: Colors.black,
      onSurface: AppColors.grey200,
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: Color(0xFF212121),
      hintStyle: TextStyle(color: Colors.grey),
      prefixIconColor: Color(0xFFB0BEC5),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        borderSide: BorderSide(color: AppColors.grey800),
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
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
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
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        foregroundColor: AppColors.grey100,
      ),
    ),
    dividerTheme: const DividerThemeData(color: AppColors.grey800),
    chipTheme: const ChipThemeData(selectedColor: AppColors.orange),
    cardTheme: const CardThemeData(
      margin: EdgeInsets.zero,
      color: Colors.black87,
      shadowColor: AppColors.grey200,
    ),
    appBarTheme: const AppBarTheme(
      color: AppColors.grey900,
      surfaceTintColor: AppColors.grey900,
    ),
    scaffoldBackgroundColor: AppColors.grey900,
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF191919),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      elevation: 4,
      backgroundColor: Colors.black,
      shadowColor: Colors.black54,
    ),
    textTheme: Typography.whiteCupertino.apply(
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
