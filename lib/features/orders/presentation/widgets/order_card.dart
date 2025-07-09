import 'package:flutter/material.dart';
import 'package:logistix/features/orders/domain/entities/order.dart';

class OrderCard extends StatelessWidget {
  const OrderCard({super.key, required this.order});
  final Order order;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: RepaintBoundary(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(order.type.icon, color: order.type.color, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      (order.dropOff ?? order.pickUp)?.formatted ??
                          order.description,
                      maxLines: 1,
                      style: theme.textTheme.bodyMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {},
                    icon: const Icon(Icons.more_horiz),
                    visualDensity: const VisualDensity(
                      vertical: -3,
                      horizontal: -4,
                    ),
                  ),
                ],
              ),
              Text(
                order.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall!.copyWith(
                  fontWeight: FontWeight.w300,
                ),
              ),
              const SizedBox(height: 8),
              OrderStatusChip(status: order.status),
              const SizedBox(height: 6),
            ],
          ),
        ),
      ),
    );
  }
}

class OrderStatusChip extends StatelessWidget {
  final OrderStatus status;
  const OrderStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(status.label),
      visualDensity: const VisualDensity(vertical: -4),
      backgroundColor: status.color.withAlpha(30),
      labelStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
        fontWeight: FontWeight.w600,
        color: status.color,
      ),
    );
  }
}
