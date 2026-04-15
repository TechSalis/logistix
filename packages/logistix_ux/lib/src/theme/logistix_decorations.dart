import 'package:flutter/material.dart';
import 'package:logistix_ux/logistix_ux.dart';

abstract class LogistixDecorations {
  static BoxDecoration card({
    Color color = LogistixColors.white,
    double? radius,
    Color? borderColor,
    bool showShadow = true,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius ?? BootstrapRadii.card),
      border: Border.all(
        color: borderColor ?? LogistixColors.border,
        width: 1.2,
      ),
      boxShadow: [
        if (showShadow)
          BoxShadow(
            color: LogistixColors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
      ],
    );
  }

  static BoxDecoration circleMotif({Color? color}) {
    return BoxDecoration(
      shape: BoxShape.circle,
      color: color ?? LogistixColors.primary.withValues(alpha: 0.04),
    );
  }
}
