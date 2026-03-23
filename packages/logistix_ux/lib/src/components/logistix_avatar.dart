import 'package:flutter/material.dart';
import 'package:logistix_ux/logistix_ux.dart';

class LogistixAvatar extends StatelessWidget {
  const LogistixAvatar({
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
    final effectiveBgColor = backgroundColor ?? LogistixColors.primary.withValues(alpha: 0.1);
    final effectiveFgColor = foregroundColor ?? LogistixColors.primary;

    final avatar = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: useGradient ? Colors.transparent : effectiveBgColor,
        shape: BoxShape.circle,
        gradient: useGradient
            ? LinearGradient(
                colors: [
                  effectiveFgColor,
                  effectiveFgColor.withValues(alpha: 0.6),
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
            color: useGradient ? Colors.white : effectiveFgColor,
            fontSize: size * 0.4,
          ),
        ),
      ),
    );

    if (statusColor == null) return avatar;

    final statusSize = size * 0.25;
    return Stack(
      children: [
        avatar,
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: statusSize,
            height: statusSize,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: statusColor!.withValues(alpha: 0.3),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
