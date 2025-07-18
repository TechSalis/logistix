import 'package:flutter/material.dart';
import 'package:logistix/app/router/app_router.dart';
import 'package:logistix/core/constants/global_instances.dart';
import 'package:logistix/app/widgets/user_avatar.dart';
import 'package:logistix/core/theme/styling.dart';
import 'package:logistix/features/orders/domain/entities/order.dart';
import 'package:logistix/features/orders/presentation/widgets/order_cards.dart';

class OrderDetailsPage extends StatelessWidget {
  const OrderDetailsPage({super.key, required this.order});
  final Order order;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rider = order.rider;
    return Scaffold(
      appBar: AppBar(title: const Text('Order Details')),
      body: ListView(
        padding: padding_16,
        children: [
          // Order Summary
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(order.type.icon, color: order.type.color, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        "Order #${order.refNumber}",
                        style: theme.textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Status:",
                        style: TextStyle(color: Colors.grey),
                      ),
                      OrderStatusChip(status: order.status),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(order.description),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Pickup & Dropoff
          if (order.pickUp != null || order.dropOff != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Locations", style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                if (order.pickUp != null)
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.store),
                      title: const Text("Pickup"),
                      subtitle: Text(order.pickUp!.name),
                    ),
                  ),
                const SizedBox(height: 8),
                if (order.dropOff != null)
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.location_on_outlined),
                      title: const Text("Drop-off"),
                      subtitle: Text(order.dropOff!.name),
                    ),
                  ),
              ],
            ),

          const SizedBox(height: 20),

          // Rider Details
          if (rider != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Rider", style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                Card(
                  child: ListTile(
                    leading: UserAvatar(user: rider),
                    title: Text(rider.name),
                    subtitle: Text(rider.phone ?? 'No Phone'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () {
                            ChatPageRoute(rider).push(context);
                          },
                          icon: const Icon(Icons.message),
                        ),
                      ],
                    ),
                    // trailing:
                    //     rider.rating != null
                    //         ? Row(
                    //           mainAxisSize: MainAxisSize.min,
                    //           children: [
                    //             Text(rider.rating!.toStringAsFixed(1)),
                    //             const Icon(
                    //               Icons.star,
                    //               color: Colors.amber,
                    //               size: 16,
                    //             ),
                    //           ],
                    //         )
                    //         : null,
                  ),
                ),
              ],
            ),

          const SizedBox(height: 20),

          // Price Summary
          Text("Payment", style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _CostRow(
                label: "Total",
                value: currencyFormatter.format(order.price),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CostRow extends StatelessWidget {
  final String label;
  final String value;

  const _CostRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
