import 'package:bootstrap/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logistix_ux/src/tokens/colors.dart';
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
        actionsPadding: const EdgeInsets.symmetric(
          horizontal: BootstrapSpacing.md,
        ),
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
          borderRadius: BorderRadius.circular(BootstrapRadii.card),
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
            horizontal: BootstrapSpacing.buttonPaddingHorizontal,
            vertical: BootstrapSpacing.buttonPaddingVertical,
          ),
          minimumSize: const Size(0, 44), // Reduced from 52
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(BootstrapRadii.button),
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: LogistixColors.primary,
          disabledForegroundColor: LogistixColors.textTertiary,
          side: const BorderSide(color: LogistixColors.border, width: 1.5),
          padding: const EdgeInsets.symmetric(
            horizontal: BootstrapSpacing.buttonPaddingHorizontal,
            vertical: BootstrapSpacing.buttonPaddingVertical,
          ),
          minimumSize: const Size(0, 44),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(BootstrapRadii.button),
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: LogistixColors.primary,
          disabledForegroundColor: LogistixColors.textTertiary,
          minimumSize: const Size(0, 44),
          padding: const EdgeInsets.symmetric(
            horizontal: BootstrapSpacing.buttonPaddingHorizontal,
            vertical: BootstrapSpacing.buttonPaddingVertical,
          ),
        ),
      ),

      // Input
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: LogistixColors.surface,
        hintStyle: LogistixTextStyles.bodyMedium.copyWith(
          color: LogistixColors.textTertiary,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: BootstrapSpacing.lg,
        ),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 40,
          minHeight: 48,
        ),
        suffixIconConstraints: const BoxConstraints(
          minWidth: 40,
          minHeight: 48,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(BootstrapRadii.input),
          borderSide: const BorderSide(
            color: LogistixColors.border,
            width: 1.2,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(BootstrapRadii.input),
          borderSide: const BorderSide(
            color: LogistixColors.border,
            width: 1.2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(BootstrapRadii.input),
          borderSide: const BorderSide(color: LogistixColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(BootstrapRadii.input),
          borderSide: const BorderSide(color: LogistixColors.error, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(BootstrapRadii.input),
          borderSide: const BorderSide(color: LogistixColors.error, width: 2),
        ),
        labelStyle: const TextStyle(
          color: LogistixColors.text,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: LogistixColors.border,
        thickness: 1,
        space: 1,
      ),

      dialogTheme: DialogThemeData(
        elevation: 0,
        backgroundColor: LogistixColors.surface,
        surfaceTintColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(BootstrapRadii.modal),
        ),
      ),

      // Bottom Sheet
      bottomSheetTheme: const BottomSheetThemeData(
        elevation: 0,
        backgroundColor: LogistixColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(BootstrapRadii.xxl),
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(BootstrapRadii.md),
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
            return const IconThemeData(color: LogistixColors.primary, size: 26);
          }
          return const IconThemeData(
            color: LogistixColors.textSecondary,
            size: 24,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          const style = LogistixTextStyles.labelSmall;
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
