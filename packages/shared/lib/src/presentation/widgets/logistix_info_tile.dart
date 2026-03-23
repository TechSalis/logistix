import 'package:flutter/material.dart';
import 'package:logistix_ux/logistix_ux.dart';

class LogistixInfoTile extends StatelessWidget {
  const LogistixInfoTile({
    required this.icon,
    required this.title,
    required this.value,
    this.iconColor,
    this.onTap,
    this.isBold = false,
    this.isDimmed = false,
    this.fontSize,
    super.key,
  });

  final IconData icon;
  final String title;
  final String value;
  final Color? iconColor;
  final VoidCallback? onTap;
  final bool isBold;
  final bool isDimmed;
  final double? fontSize;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: (iconColor ?? LogistixColors.textTertiary).withValues(
                  alpha: 0.1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 16,
                color: iconColor ?? LogistixColors.textSecondary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title.toUpperCase(),
                    style: context.textTheme.labelSmall?.copyWith(
                      color: LogistixColors.textTertiary,
                      fontWeight: FontWeight.w900,
                      fontSize: 9,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: isDimmed
                          ? LogistixColors.textTertiary
                          : LogistixColors.text,
                      fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
                      fontSize: fontSize ?? (isBold ? 14 : 13),
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.open_in_new_rounded,
                size: 14,
                color: LogistixColors.textTertiary.withValues(alpha: 0.5),
              ),
          ],
        ),
      ),
    );
  }
}
