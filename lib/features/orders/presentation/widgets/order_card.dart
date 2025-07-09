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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(order.type.icon, color: order.type.color, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    order.description,
                    maxLines: 1,
                    style: theme.textTheme.bodyMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              order.description * 2,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall!.copyWith(
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                OrderStatusChip(status: order.status),
                // const SizedBox(width: 12),
                // Text(
                //   currencyFormatter.format(order.price),
                //   style: theme.textTheme.bodyMedium,
                // ),
                const Spacer(),
                if (order.status == OrderStatus.pending)
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.all(4),
                      textStyle: theme.textTheme.labelMedium,
                      visualDensity: const VisualDensity(
                        vertical: VisualDensity.minimumDensity,
                      ),
                    ),
                    child: const Text(
                      "Cancel Order",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
          ],
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
      visualDensity: const VisualDensity(
        vertical: VisualDensity.minimumDensity,
      ),
      backgroundColor: status.color.withAlpha(30),
      labelStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: status.color,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
