import 'package:bootstrap/core.dart';
import 'package:flutter/material.dart';

class BootstrapMetricsRow extends StatelessWidget {
  const BootstrapMetricsRow({
    required this.items,
    this.padding = const EdgeInsets.symmetric(horizontal: 20),
    super.key,
  });

  final List<BootstrapMetricItem> items;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        children: items.map((item) {
          final isLast = items.indexOf(item) == items.length - 1;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: isLast ? 0 : 12),
              child: item,
            ),
          );
        }).toList(),
      ),
    );
  }
}

class BootstrapMetricItem extends StatelessWidget {
  const BootstrapMetricItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    super.key,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final effectiveBg =
        backgroundColor ?? theme.cardColor.withValues(alpha: 0.1);
    final effectiveTextColor = textColor ?? context.theme.colorScheme.surface;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: effectiveBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 6),
          if (isLoading)
            BootstrapInlineLoader(
              size: 24,
              color: effectiveTextColor.withValues(alpha: 0.7),
            )
          else
            Text(
              value,
              style: context.textTheme.titleMedium?.bold.copyWith(
                color: effectiveTextColor,
              ),
            ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: effectiveTextColor.withValues(alpha: 0.7),
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
              fontSize: 9,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
