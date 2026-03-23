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
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final LogistixButtonType type;
  final bool isLoading;
  final IconData? icon;
  final double? width;
  final double height;

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color foregroundColor;
    var borderSide = BorderSide.none;
    List<BoxShadow>? shadows;

    switch (type) {
      case LogistixButtonType.primary:
        backgroundColor = LogistixColors.primary;
        foregroundColor = Colors.white;
        if (onPressed != null && !isLoading) {
          shadows = [
            BoxShadow(
              color: LogistixColors.primary.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ];
        }
      case LogistixButtonType.secondary:
        backgroundColor = LogistixColors.primary.withValues(alpha: 0.1);
        foregroundColor = LogistixColors.primary;
      case LogistixButtonType.outline:
        backgroundColor = Colors.transparent;
        foregroundColor = LogistixColors.primary;
        borderSide = const BorderSide(color: LogistixColors.border, width: 1.5);
      case LogistixButtonType.danger:
        backgroundColor = LogistixColors.error;
        foregroundColor = Colors.white;
      case LogistixButtonType.text:
        backgroundColor = Colors.transparent;
        foregroundColor = LogistixColors.primary;
    }

    if (onPressed == null || isLoading) {
      backgroundColor =
          type == LogistixButtonType.text || type == LogistixButtonType.outline
          ? Colors.transparent
          : LogistixColors.neutral200;
      foregroundColor = LogistixColors.textTertiary;
      shadows = null;
    }

    return AnimatedScaleTap(
      onTap: isLoading ? null : onPressed,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(LogistixRadii.button),
          border: borderSide != BorderSide.none
              ? Border.fromBorderSide(borderSide)
              : null,
          boxShadow: shadows,
        ),
        child: Center(
          child: isLoading
              ? SizedBox.square(
                  dimension: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, color: foregroundColor, size: 20),
                      const SizedBox(width: 12),
                    ],
                    Text(
                      label,
                      style: context.textTheme.titleMedium?.semiBold.copyWith(
                        color: foregroundColor,
                        letterSpacing: 1.1,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
