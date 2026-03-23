import 'package:flutter/material.dart';
import 'package:logistix_ux/logistix_ux.dart';

class LogistixSettingsCard extends StatelessWidget {
  const LogistixSettingsCard({
    required this.children,
    this.title,
    super.key,
  });

  final List<Widget> children;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              title!,
              style: context.textTheme.labelMedium?.bold.copyWith(
                color: LogistixColors.textSecondary,
                letterSpacing: 0.8,
                fontSize: 12,
              ),
            ),
          ),
        ],
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: children
                .asMap()
                .entries
                .map((entry) {
                  final i = entry.key;
                  final widget = entry.value;
                  return Column(
                    children: [
                      if (i > 0)
                        Divider(
                          height: 1,
                          indent: 56,
                          color: LogistixColors.border.withValues(alpha: 0.4),
                        ),
                      widget,
                    ],
                  );
                })
                .toList(),
          ),
        ),
      ],
    );
  }
}

class LogistixSettingsTile extends StatelessWidget {
  const LogistixSettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.iconColor,
    this.titleColor,
    this.trailing,
    super.key,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? titleColor;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return AnimatedScaleTap(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (iconColor ?? LogistixColors.primary).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 20,
                color: iconColor ?? LogistixColors.textSecondary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: context.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: titleColor ?? LogistixColors.text,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: context.textTheme.labelSmall?.copyWith(
                        color: LogistixColors.textTertiary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null)
              trailing!
            else if (onTap != null)
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: LogistixColors.textTertiary.withValues(alpha: 0.6),
              ),
          ],
        ),
      ),
    );
  }
}
