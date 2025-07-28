import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:logistix/app/widgets/buttons.dart';
import 'package:logistix/app/widgets/status_dialogs.dart';
import 'package:logistix/core/constants/objects.dart';
import 'package:logistix/core/theme/styling.dart';
import 'package:logistix/features/auth/presentation/utils/auth_network_image.dart';
import 'package:logistix/features/home/domain/entities/rider_data.dart';
import 'package:logistix/features/orders/application/logic/orders_rp.dart';
import 'package:logistix/features/orders/domain/entities/order.dart';
import 'package:logistix/features/orders/presentation/widgets/order_cards.dart';
import 'package:logistix/features/rider/presentation/widgets/rider_tracker_widget.dart';
import 'package:progress_state_button/progress_button.dart';

class RiderInfoCard extends StatelessWidget {
  final RiderData rider;

  const RiderInfoCard({super.key, required this.rider});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage:
              rider.imageUrl != null ? AppNetworkImage(rider.imageUrl!) : null,
          child: rider.imageUrl == null ? const Icon(Icons.person) : null,
        ),
        title: Text(rider.name),
        subtitle: Text(rider.phone ?? 'No contact'),
        trailing: IconButton(
          icon: const Icon(Icons.call),
          onPressed: () {
            // Implement phone call
          },
        ),
      ),
    );
  }
}

class OrderSummaryCard extends StatelessWidget {
  final Order order;

  const OrderSummaryCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: padding_H16_V12,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text("Order  ", style: theme.textTheme.titleMedium),
                OrderRefNumberChip(refNumber: order.refNumber),
              ],
            ),
            const SizedBox(height: 12),
            Text(order.description, style: theme.textTheme.bodyMedium),
            const Divider(height: 24),
            Row(
              children: [
                if (order.price != null)
                  Text(
                    currencyFormatter.format(order.price!),
                    style: theme.textTheme.titleLarge,
                  ),
                const Spacer(),
                OrderStatusChip(status: order.status),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class LocationTile extends StatelessWidget {
  final String label;
  final String? address;
  final IconData icon;

  const LocationTile({
    super.key,
    required this.label,
    this.address,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      subtitle: Text(address ?? "Not set"),
    );
  }
}

class OrderDetailsPage extends StatelessWidget {
  final Order order;
  const OrderDetailsPage({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ValueNotifier(ButtonState.idle);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          if (order.rider == null)
            const SliverAppBar(pinned: true, title: Text("Order Details"))
          else
            SliverAppBar(
              pinned: true,
              expandedHeight: 220,
              flexibleSpace: FlexibleSpaceBar(
                title: const Text("Order Details"),
                background: RiderTrackerMapWidget(rider: order.rider!),
              ),
            ),
          SliverToBoxAdapter(
            child: Padding(
              padding: padding_16,
              child: Column(
                children: [
                  OrderSummaryCard(order: order),
                  const SizedBox(height: 12),
                  LocationTile(
                    label: "Pickup",
                    icon: Icons.my_location,
                    address: order.pickup?.name,
                  ),
                  LocationTile(
                    label: "Drop-off",
                    icon: Icons.location_on,
                    address: order.dropoff?.name,
                  ),
                  if (order.rider != null) RiderInfoCard(rider: order.rider!),
                  if (order.status == OrderStatus.pending)
                    Padding(
                      padding: const EdgeInsets.only(top: 32),
                      child: Consumer(
                        builder: (context, ref, _) {
                          ref.listen(cancelOrderProvider, (p, n) {
                            switch (n) {
                              case AsyncLoading():
                                state.value = ButtonState.loading;
                                break;
                              case AsyncData():
                                state.value = ButtonState.success;
                                break;
                              case AsyncError():
                                state.value = ButtonState.fail;
                                break;
                            }
                          });
                          // }
                          return ElevatedLoadingButton(
                            onPressed: () {
                              showConfirmDialog(
                                context,
                                title: "Cancel Order",
                                message:
                                    "Are you sure you want to cancel this order?",
                                confirmButton: FilledButton(
                                  onPressed: () {
                                    ref
                                        .read(cancelOrderProvider.notifier)
                                        .cancelOrder(order);
                                    context.pop();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: theme.colorScheme.error,
                                    foregroundColor: theme.colorScheme.onError,
                                  ),
                                  child: const Text("Cancel Order"),
                                ),
                              );
                            },
                            state: state,
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check_circle_outline),
                                SizedBox(width: 8),
                                Text("Cancel Order"),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
