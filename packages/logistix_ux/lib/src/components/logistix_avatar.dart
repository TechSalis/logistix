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
    final backgroundColor = this.backgroundColor ??
        LogistixColors.primary.withValues(alpha: 0.1);
    final foregroundColor = this.foregroundColor ?? LogistixColors.primary;

    final avatar = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: useGradient ? Colors.transparent : backgroundColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: (useGradient ? foregroundColor : backgroundColor)
                .withValues(alpha: 0.2),
            blurRadius: size * 0.2,
            spreadRadius: size * 0.05,
          ),
        ],
        border: Border.all(
          color: (useGradient ? Colors.white : foregroundColor)
              .withValues(alpha: 0.2),
          width: size * 0.04,
        ),
        gradient: useGradient
            ? LinearGradient(
                colors: [
                  foregroundColor,
                  foregroundColor.withValues(alpha: 0.7),
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
            color: useGradient ? Colors.white : foregroundColor,
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
