import 'package:flutter/material.dart';
import 'package:logistix/features/rider/domain/entities/rider.dart';

class RiderCardSmall extends StatelessWidget {
  const RiderCardSmall({super.key, required this.rider, this.eta});

  final Rider rider;
  final String? eta;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        border: Border.all(color: theme.dividerColor.withAlpha(26)),
        boxShadow: const [
          BoxShadow(blurRadius: 8, color: Colors.black12, offset: Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Theme.of(context).highlightColor,
            child: Text(
              rider.name[0].toUpperCase(),
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rider.name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  rider.company ?? 'Independent',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.hintColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (eta != null) ...[ETAWidget(eta: eta!), const SizedBox(width: 8)],
          IconButton(
            onPressed: () {},
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.chat_bubble_outline, size: 20),
          ),
          const SizedBox(width: 4),
          IconButton(
            onPressed: () {},
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.help_outline, size: 20),
          ),
        ],
      ),
    );
  }
}

class ETAWidget extends StatelessWidget {
  const ETAWidget({super.key, required this.eta});
  final String eta;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).iconTheme.color?.withAlpha(160);
    return Column(
      children: [
        Icon(Icons.timer_outlined, size: 16, color: color),
        const SizedBox(height: 2),
        Text(eta, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
