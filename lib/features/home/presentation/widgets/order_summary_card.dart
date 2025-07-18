import 'package:flutter/material.dart';
import 'package:logistix/core/theme/styling.dart';
import 'package:logistix/features/orders/domain/entities/order_responses.dart';
import 'package:logistix/features/orders/presentation/widgets/order_cards.dart';

class HomeOrderSummaryCard extends StatelessWidget {
  final Order? order;
  final VoidCallback? onTap;

  const HomeOrderSummaryCard({super.key, required this.order, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (order == null) {
      // No orders yet
      return Card(
        shape: roundRectBorder12,
        child: Padding(
          padding: padding_16,
          child: Center(
            child: Column(
              children: [
                const Icon(Icons.moped, size: 40, color: Colors.grey),
                const SizedBox(height: 12),
                Text("No orders yet", style: theme.textTheme.titleMedium),
                const SizedBox(height: 6),
                const Text(
                  "Start your first delivery to see order updates here.",
                  style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: onTap,
                  child: const Text("Place an Order"),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return Card(
      shape: roundRectBorder12,
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius_12,
        child: Padding(
          padding: padding_H16_V12,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Header
              Row(
                children: [
                  Icon(
                    order!.orderType.icon,
                    color: order!.orderType.color,
                    size: 28,
                  ),
                  const SizedBox(width: 8),
                  OrderRefNumberChip(order: order!),
                  const Spacer(),
                  OrderStatusChip(status: order!.orderStatus),
                ],
              ),
              const SizedBox(height: 12),

              /// Pickup → Dropoff
              OrderLocationRow(
                icon: Icons.store,
                label: order!.pickup?.name ?? "N/A",
              ),
              OrderLocationRow(
                icon: Icons.pin_drop_outlined,
                label: order!.dropoff?.name ?? "N/A",
              ),
              const SizedBox(height: 12),

              /// Description
              Expanded(
                child: Text(
                  '"${order!.description}"',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: theme.hintColor,
                  ),
                  maxLines: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
