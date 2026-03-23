import 'package:flutter/material.dart';
import 'package:logistix_ux/logistix_ux.dart';

/// A premium error view component for displaying failures in a user-friendly way.
class LogistixErrorView extends StatelessWidget {
  const LogistixErrorView({
    required this.message,
    this.title = 'Oops!',
    this.onRetry,
    this.icon = Icons.error_outline_rounded,
    this.textColor,
    this.iconColor,
    super.key,
  });

  const LogistixErrorView.small({
    required this.message,
    this.onRetry,
    this.textColor,
    this.iconColor,
    super.key,
  }) : title = null,
       icon = Icons.refresh_rounded;

  final String? title;
  final String message;
  final VoidCallback? onRetry;
  final IconData icon;
  final Color? textColor;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final isSmall = title == null;

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!isSmall) ...[
          Container(
            padding: const EdgeInsets.all(LogistixSpacing.lg),
            decoration: BoxDecoration(
              color: (iconColor ?? LogistixColors.error).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 64,
              color: iconColor ?? LogistixColors.error,
            ),
          ),
          const SizedBox(height: LogistixSpacing.lg),
          Text(
            title ?? '',
            style: context.textTheme.headlineSmall?.bold.copyWith(
              color: textColor ?? LogistixColors.text,
            ),
          ),
          const SizedBox(height: LogistixSpacing.xs),
        ] else ...[
          Icon(icon, size: 32, color: iconColor ?? LogistixColors.error),
          const SizedBox(height: LogistixSpacing.sm),
        ],
        Text(
          message,
          textAlign: TextAlign.center,
          style: context.textTheme.bodyMedium?.copyWith(
            color: textColor ?? LogistixColors.textSecondary,
          ),
        ),
        if (onRetry != null && !isSmall) ...[
          const SizedBox(height: LogistixSpacing.xl),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Try Again'),
          ),
        ],
      ],
    );

    return Center(
      child: Padding(
        padding: EdgeInsets.all(
          isSmall ? LogistixSpacing.md : LogistixSpacing.lg,
        ),
        child: isSmall && onRetry != null
            ? AnimatedScaleTap(onTap: onRetry, child: content)
            : content,
      ),
    );
  }
}
