import 'package:flutter/material.dart';
import 'package:logistix_ux/logistix_ux.dart';

class LogistixEmptyView extends StatelessWidget {
  const LogistixEmptyView({
    required this.icon,
    required this.title,
    this.description,
    this.action,
    super.key,
  });

  final IconData icon;
  final String title;
  final String? description;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: LogistixColors.primary.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 64,
                color: LogistixColors.textTertiary.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: context.textTheme.titleMedium?.bold.copyWith(
                color: LogistixColors.textSecondary,
              ),
            ),
            if (description != null) ...[
              const SizedBox(height: 8),
              Text(
                description!,
                textAlign: TextAlign.center,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: LogistixColors.textTertiary,
                ),
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: 24),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
