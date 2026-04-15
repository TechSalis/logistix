import 'package:bootstrap/core.dart';
import 'package:flutter/material.dart';

class BootstrapAvatar extends StatelessWidget {
  const BootstrapAvatar({
    required this.name,
    this.size = 48.0,
    this.statusColor,
    this.backgroundColor,
    this.foregroundColor,
    this.useGradient = false,
    super.key,
  });

  final String? name;
  final double size;
  final Color? statusColor;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool useGradient;

  @override
  Widget build(BuildContext context) {
    // Falls back to theme primary if colors not provided
    final theme = context.theme;
    final effectiveBackground = backgroundColor ??
        theme.primaryColor.withValues(alpha: 0.1);
    final effectiveForeground = foregroundColor ?? theme.primaryColor;

    final avatar = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: useGradient ? Colors.transparent : effectiveBackground,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: (useGradient ? effectiveForeground : effectiveBackground)
                .withValues(alpha: 0.2),
            blurRadius: size * 0.2,
            spreadRadius: size * 0.05,
          ),
        ],
        border: Border.all(
          color: (useGradient ? Colors.white : effectiveForeground)
              .withValues(alpha: 0.2),
          width: size * 0.04,
        ),
        gradient: useGradient
            ? LinearGradient(
                colors: [
                  effectiveForeground,
                  effectiveForeground.withValues(alpha: 0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
      ),
      child: Center(
        child: Text(
          name?.initials ?? '?',
          style: context.textTheme.titleMedium?.bold.copyWith(
            color: useGradient ? Colors.white : effectiveForeground,
            fontSize: size * 0.38,
            letterSpacing: -0.5,
          ),
        ),
      ),
    );

    if (statusColor == null) return avatar;

    final statusSize = size * 0.28;
    return Stack(
      children: [
        avatar,
        Positioned(
          bottom: size * 0.02,
          right: size * 0.02,
          child: Container(
            width: statusSize,
            height: statusSize,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: size * 0.03),
              boxShadow: [
                BoxShadow(
                  color: statusColor!.withValues(alpha: 0.5),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
