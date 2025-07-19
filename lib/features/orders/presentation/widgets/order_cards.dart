import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logistix/core/theme/styling.dart';
import 'package:logistix/features/orders/domain/entities/base_order_data.dart';
import 'package:logistix/features/orders/domain/entities/order_responses.dart';

class EtaWidget extends StatelessWidget {
  const EtaWidget({super.key, required this.eta});
  final String? eta;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: "ETA: ",
        children: [
          TextSpan(
            text: eta ?? '--:--',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ],
        style: Theme.of(
          context,
        ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w400),
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
      backgroundColor: status.color.withAlpha(40),
      shape: const LinearBorder(),
      labelStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
        fontWeight: FontWeight.w600,
        color: status.color,
      ),
    );
  }
}

class OrderRefNumberChip extends StatelessWidget {
  const OrderRefNumberChip({super.key, required this.order});
  final Order order;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      backgroundColor: Theme.of(context).highlightColor,
      label: Row(
        children: [
          Text("#${order.refNumber}  "),
          const Icon(Icons.copy, size: 14),
        ],
      ),
      visualDensity: const VisualDensity(vertical: -4),
      onPressed: () {
        Clipboard.setData(ClipboardData(text: order.refNumber.toString()));
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Copied to clipboard")));
      },
    );
  }
}

class OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback onTap;

  const OrderCard({super.key, required this.order, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      // elevation: 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius_8,
        child: Padding(
          padding: padding_H16_V12,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(order.orderType.icon, size: 22),
                  const SizedBox(width: 8),
                  OrderRefNumberChip(order: order),
                  const Spacer(),
                  OrderStatusChip(status: order.orderStatus),
                ],
              ),
              const SizedBox(height: 8),

              /// Pickup and Dropoff
              if (order.pickup != null)
                OrderLocationRow(
                  icon: Icons.store,
                  label: order.pickup!.name,
                ),
              if (order.dropoff != null)
                OrderLocationRow(
                  icon: Icons.location_on_outlined,
                  label: order.dropoff!.name,
                ),
              const SizedBox(height: 12),
              /// Price and Order Type
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [EtaWidget(eta: '20 min')],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OrderLocationRow extends StatelessWidget {
  const OrderLocationRow({super.key, required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
