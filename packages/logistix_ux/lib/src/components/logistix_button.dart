import 'package:flutter/material.dart';
import 'package:logistix_ux/logistix_ux.dart';

enum LogistixButtonType { primary, secondary, outline, text, danger }

class LogistixButton extends StatelessWidget {
  const LogistixButton({
    required this.label,
    required this.onPressed,
    this.type = LogistixButtonType.primary,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height = 48,
    this.backgroundColor,
    this.foregroundColor,
    this.padding,
    this.fontSize,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final LogistixButtonType type;
  final bool isLoading;
  final IconData? icon;
  final double? width;
  final double height;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final EdgeInsetsGeometry? padding;
  final double? fontSize;

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    var borderSide = BorderSide.none;
    List<BoxShadow>? shadows;

    final isDisabled = onPressed == null || isLoading;

    switch (type) {
      case LogistixButtonType.primary:
        bg = LogistixColors.primary;
        fg = Colors.white;
        if (!isDisabled) {
          shadows = [
            BoxShadow(
              color: LogistixColors.primary.withValues(alpha: 0.25),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ];
        }
      case LogistixButtonType.secondary:
        bg = LogistixColors.primary.withValues(alpha: 0.1);
        fg = LogistixColors.primary;
      case LogistixButtonType.outline:
        bg = Colors.transparent;
        fg = LogistixColors.primary;
        borderSide = BorderSide(
          color: backgroundColor ?? LogistixColors.border,
          width: 1.5,
        );
      case LogistixButtonType.danger:
        bg = LogistixColors.error;
        fg = Colors.white;
      case LogistixButtonType.text:
        bg = Colors.transparent;
        fg = LogistixColors.primary;
    }

    // Explicit overrides
    if (backgroundColor != null && type != LogistixButtonType.outline) {
      bg = backgroundColor!;
    }
    
    if (foregroundColor != null) fg = foregroundColor!;

    if (isDisabled) {
      if (type != LogistixButtonType.text &&
          type != LogistixButtonType.outline) {
        bg = LogistixColors.neutral200;
      }
      fg = LogistixColors.textTertiary;
      shadows = null;
    }

    return AnimatedScaleTap(
      onTap: isDisabled ? null : onPressed,
      child: Container(
        width: width,
        height: height,
        padding:
            padding ??
            const EdgeInsets.symmetric(horizontal: LogistixSpacing.md),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(LogistixRadii.button),
          border: borderSide != BorderSide.none
              ? Border.fromBorderSide(borderSide)
              : null,
          boxShadow: shadows,
        ),
        child: Center(
          child: isLoading
              ? LogistixInlineLoader(color: fg)
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, color: fg, size: 20),
                      const SizedBox(width: LogistixSpacing.xs),
                    ],
                    Text(
                      label,
                      style: context.textTheme.titleSmall?.semiBold.copyWith(
                        color: fg,
                        fontSize: fontSize,
                        height: 1.2,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
