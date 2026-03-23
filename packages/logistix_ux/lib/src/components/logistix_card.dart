import 'package:flutter/material.dart';
import 'package:logistix_ux/logistix_ux.dart';

class LogistixCard extends StatelessWidget {
  const LogistixCard({
    required this.child,
    super.key,
    this.padding = const EdgeInsets.all(LogistixSpacing.cardPadding),
    this.width,
    this.height,
    this.color = Colors.white,
    this.borderColor,
    this.shadowColor,
    this.borderRadius,
    this.margin,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double? width;
  final double? height;
  final Color color;
  final Color? borderColor;
  final Color? shadowColor;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Widget card = Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: color,
        borderRadius: borderRadius ?? BorderRadius.circular(LogistixRadii.card),
        border: Border.all(
          color: borderColor ?? LogistixColors.border,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: shadowColor ?? Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(LogistixRadii.card),
        child: Padding(padding: padding, child: child),
      ),
    );

    if (onTap != null) {
      return AnimatedScaleTap(onTap: onTap, child: card);
    }

    return card;
  }
}
