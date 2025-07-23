import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:logistix/app/widgets/user_avatar.dart';
import 'package:logistix/core/theme/styling.dart';
import 'package:logistix/features/auth/domain/entities/user_data.dart';
import 'package:logistix/features/notifications/application/notification_service.dart';
import 'package:logistix/features/orders/domain/entities/base_order_data.dart';
import 'package:logistix/features/orders/domain/entities/order_responses.dart';

class OrderStatusChip extends StatelessWidget {
  final OrderStatus status;
  const OrderStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Chip(
      // label: Text('🔥 Near you!'),
      label: Text(status.label),
      visualDensity: const VisualDensity(vertical: -3),
      backgroundColor: status.color.withAlpha(40),
      shape: const LinearBorder(),
      labelStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: status.color,
      ),
    );
  }
}

class _OrderRefNumberChip extends StatelessWidget {
  const _OrderRefNumberChip({required this.refNumber});
  final int refNumber;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      backgroundColor: Theme.of(context).colorScheme.onSurface.withAlpha(30),
      label: Text(
        "# $refNumber",
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
      visualDensity: const VisualDensity(vertical: -3),
      onPressed: () {
        Clipboard.setData(ClipboardData(text: refNumber.toString()));
        NotificationService.inApp.showToast("Copied to clipboard");
      },
    );
  }
}

class _OrderLocationRow extends StatelessWidget {
  const _OrderLocationRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 18),
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

class _RiderSectionWidget extends StatelessWidget {
  const _RiderSectionWidget({required this.rider});

  final UserData? rider;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (rider == null)
          const Text("Waiting for rider...", maxLines: 1)
        else ...[
          UserAvatar(radius: 16, user: rider!),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              rider?.name ?? "Rider Assigned",
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
          IconButton(
            padding: EdgeInsets.zero,
            visualDensity: const VisualDensity(vertical: -1, horizontal: -1),
            icon: const Icon(Icons.call),
            onPressed: () {
              // callRider(order!.rider?.phone);
            },
          ),
          IconButton(
            padding: EdgeInsets.zero,
            visualDensity: const VisualDensity(vertical: -1, horizontal: -1),
            icon: const Icon(Icons.location_on),
            onPressed: () {},
          ),
        ],
      ],
    );
  }
}

class OrderPreviewCard extends StatelessWidget {
  const OrderPreviewCard({super.key, required this.order});
  final Order? order;

  @override
  Widget build(BuildContext context) {
    if (order == null) {
      return Card(
        child: Padding(
          padding: padding_H16_V12,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.format_list_numbered_outlined,
                  size: 40,
                  color: Colors.grey,
                ),
                const SizedBox(height: 12),
                Text(
                  "No orders yet",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                const Text(
                  "Start your first order. Tap on any button above.",
                  style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }
    return Card(
      elevation: 3,
      shadowColor: Colors.black54,
      child: Padding(
        padding: padding_H16_V12,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  order!.orderType.icon,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                const SizedBox(width: 12),
                _OrderRefNumberChip(refNumber: order!.refNumber),
                const Spacer(),
                OrderStatusChip(status: order!.orderStatus),
              ],
            ),
            SizedBox(height: 12.h),
            if (order!.pickup != null)
              _OrderLocationRow(icon: Icons.store, label: order!.pickup!.name),
            if (order!.dropoff != null)
              _OrderLocationRow(
                icon: Icons.location_on_outlined,
                label: order!.dropoff!.name,
              ),
            //  Text(
            //     '"${order!.description}"',
            //     style: Theme.of(
            //       context,
            //     ).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
            //   ),
            const Spacer(),
            const Divider(height: 16),
            // SizedBox(height: 8),
            SizedBox(
              height: 40,
              child: _RiderSectionWidget(rider: order!.rider),
            ),
          ],
        ),
      ),
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
      elevation: 6,
      shadowColor: Colors.black26,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius_16,
        child: Padding(
          padding: padding_16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Icon(
                      order.orderType.icon,
                      color: Theme.of(
                        context,
                      ).colorScheme.secondary.withAlpha(100),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _OrderRefNumberChip(refNumber: order.refNumber),
                        const SizedBox(height: 8),

                        /// Pickup and Dropoff
                        if (order.pickup != null)
                          _OrderLocationRow(
                            icon: Icons.store,
                            label: order.pickup!.name,
                          ),
                        if (order.dropoff != null)
                          _OrderLocationRow(
                            icon: Icons.location_on_outlined,
                            label: order.dropoff!.name,
                          ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      OrderStatusChip(status: order.orderStatus),
                      const Chip(label: Text('8 min')),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(
                      text: 'Description: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: '"${order.description}"',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
                maxLines: 1,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 4),
              if (order.rider != null) ...[
                const Divider(height: 32),
                SizedBox(
                  height: 32,
                  child: _RiderSectionWidget(rider: order.rider),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
