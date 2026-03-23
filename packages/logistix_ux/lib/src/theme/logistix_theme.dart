import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logistix_ux/src/theme/extensions/theme_extensions.dart';
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
        titleTextStyle: LogistixTextStyles.titleLarge.bold.copyWith(
          color: LogistixColors.text,
        ),
        toolbarTextStyle: LogistixTextStyles.bodyMedium.copyWith(
          color: LogistixColors.text,
        ),
      ),

      // Card
      cardTheme: CardThemeData(
        elevation: 0,
        color: LogistixColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: LogistixRadii.borderRadiusCard,
          side: const BorderSide(color: LogistixColors.border, width: 1.2),
        ),
        margin: EdgeInsets.zero,
      ),

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
          minimumSize: const Size(0, 52), // Premium height
          textStyle: LogistixTextStyles.titleMedium.bold.copyWith(
            fontSize: 15,
            letterSpacing: 1.1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(LogistixRadii.button),
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: LogistixColors.primary,
          disabledForegroundColor: LogistixColors.textTertiary,
          side: const BorderSide(color: LogistixColors.border, width: 1.5),
          padding: const EdgeInsets.symmetric(
            horizontal: LogistixSpacing.buttonPaddingHorizontal,
            vertical: LogistixSpacing.buttonPaddingVertical,
          ),
          minimumSize: const Size(0, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(LogistixRadii.button),
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: LogistixColors.primary,
          disabledForegroundColor: LogistixColors.textTertiary,
          minimumSize: const Size(0, 52),
          padding: const EdgeInsets.symmetric(
            horizontal: LogistixSpacing.buttonPaddingHorizontal,
            vertical: LogistixSpacing.buttonPaddingVertical,
          ),
          textStyle: LogistixTextStyles.bodyLarge.semiBold,
        ),
      ),

      // Input
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: LogistixColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(LogistixRadii.input),
          borderSide: const BorderSide(color: LogistixColors.border, width: 1.2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(LogistixRadii.input),
          borderSide: const BorderSide(color: LogistixColors.border, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(LogistixRadii.input),
          borderSide: const BorderSide(color: LogistixColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(LogistixRadii.input),
          borderSide: const BorderSide(color: LogistixColors.error, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(LogistixRadii.input),
          borderSide: const BorderSide(color: LogistixColors.error, width: 2),
        ),
        hintStyle: const TextStyle(color: LogistixColors.textSecondary, fontSize: 14),
        labelStyle: const TextStyle(color: LogistixColors.text, fontSize: 14, fontWeight: FontWeight.w500),
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
        insetPadding: EdgeInsets.all(20),
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
 
      // Navigation Bar
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: LogistixColors.surface,
        indicatorColor: LogistixColors.primary.withValues(alpha: 0.1),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        height: 70,
        elevation: 0,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(
              color: LogistixColors.primary,
              size: 26,
            );
          }
          return const IconThemeData(
            color: LogistixColors.textSecondary,
            size: 24,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final style = LogistixTextStyles.labelSmall;
          if (states.contains(WidgetState.selected)) {
            return style.bold.copyWith(
              color: LogistixColors.primary,
              fontSize: 12,
            );
          }
          return style.medium.copyWith(
            color: LogistixColors.textSecondary,
            fontSize: 12,
          );
        }),
      ),
    );
  }

  static ThemeData get darkTheme => lightTheme;
}
