import 'package:flutter/material.dart';
import 'package:logistix/features/rider/domain/entities/rider.dart';

class RiderCard extends StatelessWidget {
  const RiderCard({super.key, required this.rider, this.eta});

  final Rider rider;
  final String? eta;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: theme.colorScheme.primary.withAlpha(26),
          child: Text(
            rider.name[0].toUpperCase(),
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                rider.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (rider.company != null)
                Text(
                  rider.company!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.hintColor,
                  ),
                ),
              const SizedBox(height: 6),
              Row(
                children: [
                  if (rider.rating > 0) ...[
                    const Icon(Icons.star, size: 16, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      rider.rating.toStringAsFixed(1),
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                  if (eta != null) ...[
                    const Spacer(),
                    const Icon(Icons.timer_outlined, size: 16),
                    const SizedBox(width: 4),
                    Text(eta!, style: theme.textTheme.bodySmall),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
