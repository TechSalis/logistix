import 'package:flutter/material.dart';
import 'package:logistix_ux/logistix_ux.dart';

class LogistixMetricsRow extends StatelessWidget {
  const LogistixMetricsRow({
    required this.items,
    this.padding = const EdgeInsets.symmetric(horizontal: 20),
    super.key,
  });

  final List<LogistixMetricItem> items;
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

class LogistixMetricItem extends StatelessWidget {
  const LogistixMetricItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.isLoading = false,
    super.key,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color? color;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
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
              color: color?.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 6),
          if (isLoading)
            const SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white70,
              ),
            )
          else
            Text(
              value,
              style: context.textTheme.headlineSmall?.bold.copyWith(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: context.textTheme.labelSmall?.copyWith(
              color: Colors.white70,
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
