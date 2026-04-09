import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:logistix_ux/logistix_ux.dart';

class LogistixSuccessView extends StatelessWidget {
  const LogistixSuccessView({
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(LogistixSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: LogistixColors.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: LogistixColors.success,
                size: 60,
              ),
            )
                .animate()
                .scale(
                  duration: 600.ms,
                  curve: Curves.easeOutBack,
                  begin: const Offset(0.5, 0.5),
                )
                .shimmer(delay: 400.ms, duration: 1.seconds),
            const SizedBox(height: LogistixSpacing.xxl),
            Text(
              title,
              textAlign: TextAlign.center,
              style: context.textTheme.headlineSmall?.bold,
            ).animate().fade(delay: 200.ms).slideY(begin: 0.2),
            const SizedBox(height: LogistixSpacing.md),
            Text(
              message,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyLarge?.copyWith(
                color: LogistixColors.textSecondary,
              ),
            ).animate().fade(delay: 400.ms).slideY(begin: 0.2),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: LogistixSpacing.xxl),
              LogistixButton(
                label: actionLabel!,
                onPressed: onAction,
                width: 200,
              ).animate().fade(delay: 600.ms).scale(begin: const Offset(0.9, 0.9)),
            ],
          ],
        ),
      ),
    );
  }
}
