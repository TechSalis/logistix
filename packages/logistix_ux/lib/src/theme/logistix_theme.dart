import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logistix_ux/src/tokens/colors.dart';
import 'package:logistix_ux/src/tokens/radii.dart';
import 'package:logistix_ux/src/tokens/spacing.dart';
import 'package:logistix_ux/src/typography/text_styles.dart';

class LogistixTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: LogistixTextStyles.fontFamily,

      // Color Scheme
      colorScheme: const ColorScheme.light(
        primary: LogistixColors.primary,
        primaryContainer: LogistixColors.primaryLight,
        onPrimaryContainer: LogistixColors.primaryDark,
        secondary: LogistixColors.info,
        onSecondary: LogistixColors.textOnPrimary,
        error: LogistixColors.error,
        onSurface: LogistixColors.text,
        surfaceContainerHighest: LogistixColors.neutral100,
        outline: LogistixColors.border,
        outlineVariant: LogistixColors.borderStrong,
        shadow: Colors.black,
        scrim: Colors.black,
      ),

      scaffoldBackgroundColor: LogistixColors.background,
      // AppBar
      appBarTheme: AppBarTheme(
        elevation: 0,
        // scrolledUnderElevation: 1,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: LogistixColors.text,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: LogistixTextStyles.titleLarge.copyWith(
          color: LogistixColors.text,
        ),
      ),

      // Card
      cardTheme: const CardThemeData(
        elevation: 0,
        color: LogistixColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: LogistixRadii.borderRadiusCard,
          side: BorderSide(color: LogistixColors.border),
        ),
        margin: EdgeInsets.zero,
      ),

      // Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: LogistixColors.primary,
          foregroundColor: LogistixColors.textOnPrimary,
          disabledBackgroundColor: LogistixColors.neutral200,
          disabledForegroundColor: LogistixColors.textTertiary,
          padding: const EdgeInsets.symmetric(
            horizontal: LogistixSpacing.buttonPaddingHorizontal,
            vertical: LogistixSpacing.buttonPaddingVertical,
          ),
          minimumSize: const Size(0, 44),
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
          shape: const RoundedRectangleBorder(
            borderRadius: LogistixRadii.borderRadiusButton,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: LogistixColors.primary,
          disabledForegroundColor: LogistixColors.textTertiary,
          side: const BorderSide(color: LogistixColors.border),
          padding: const EdgeInsets.symmetric(
            horizontal: LogistixSpacing.buttonPaddingHorizontal,
            vertical: LogistixSpacing.buttonPaddingVertical,
          ),
          minimumSize: const Size(0, 44),
          shape: const RoundedRectangleBorder(
            borderRadius: LogistixRadii.borderRadiusButton,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: LogistixColors.primary,
          disabledForegroundColor: LogistixColors.textTertiary,
          minimumSize: const Size(0, 44),
        ),
      ),

      // Input
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: LogistixColors.surface,
        contentPadding: EdgeInsets.symmetric(
          horizontal: LogistixSpacing.inputPaddingHorizontal,
          vertical: LogistixSpacing.inputPaddingVertical,
        ),
        border: OutlineInputBorder(
          borderRadius: LogistixRadii.borderRadiusInput,
          borderSide: BorderSide(color: LogistixColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: LogistixRadii.borderRadiusInput,
          borderSide: BorderSide(color: LogistixColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: LogistixRadii.borderRadiusInput,
          borderSide: BorderSide(color: LogistixColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: LogistixRadii.borderRadiusInput,
          borderSide: BorderSide(color: LogistixColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: LogistixRadii.borderRadiusInput,
          borderSide: BorderSide(color: LogistixColors.error, width: 2),
        ),
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: LogistixColors.border,
        thickness: 1,
        space: 1,
      ),

      // Dialog
      dialogTheme: const DialogThemeData(
        elevation: 0,
        backgroundColor: LogistixColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: LogistixRadii.borderRadiusDialog,
        ),
      ),

      // Bottom Sheet
      bottomSheetTheme: const BottomSheetThemeData(
        elevation: 0,
        backgroundColor: LogistixColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(LogistixRadii.xxl),
          ),
        ),
        showDragHandle: true,
      ),

      // Snackbar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: LogistixColors.neutral800,
        contentTextStyle: LogistixTextStyles.bodyMedium.copyWith(
          color: LogistixColors.textOnPrimary,
        ),
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(
          borderRadius: LogistixRadii.borderRadiusMd,
        ),
      ),

      // Progress Indicator
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: LogistixColors.primary,
        linearTrackColor: LogistixColors.neutral200,
        circularTrackColor: LogistixColors.neutral200,
      ),

      // Typography
      textTheme: const TextTheme(
        displayLarge: LogistixTextStyles.displayLarge,
        displayMedium: LogistixTextStyles.displayMedium,
        displaySmall: LogistixTextStyles.displaySmall,
        headlineLarge: LogistixTextStyles.headlineLarge,
        headlineMedium: LogistixTextStyles.headlineMedium,
        headlineSmall: LogistixTextStyles.headlineSmall,
        titleLarge: LogistixTextStyles.titleLarge,
        titleMedium: LogistixTextStyles.titleMedium,
        titleSmall: LogistixTextStyles.titleSmall,
        bodyLarge: LogistixTextStyles.bodyLarge,
        bodyMedium: LogistixTextStyles.bodyMedium,
        bodySmall: LogistixTextStyles.bodySmall,
        labelLarge: LogistixTextStyles.labelLarge,
        labelMedium: LogistixTextStyles.labelMedium,
        labelSmall: LogistixTextStyles.labelSmall,
      ),
    );
  }

  static ThemeData get darkTheme => lightTheme;
}
