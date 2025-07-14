import 'package:flutter/material.dart';
import 'package:logistix/app/domain/entities/rider_data.dart';
import 'package:logistix/core/constants/global_instances.dart';
import 'package:logistix/core/theme/styling.dart';
import 'package:logistix/app/presentation/widgets/user_avatar.dart';
import 'package:logistix/features/orders/domain/entities/order.dart';

class OrderDetailsSheet extends StatelessWidget {
  const OrderDetailsSheet({super.key, required this.order, this.rider});
  final Order order;
  final RiderData? rider;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      top: false,
      left: false,
      right: false,
      child: Padding(
        padding: padding_H16,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Summary',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (order.pickUp != null)
              _InfoSection(
                icon: Icons.location_pin,
                label: 'From',
                value: order.pickUp!.formatted,
              ),
            if (order.dropOff != null)
              _InfoSection(
                icon: Icons.flag,
                label: 'To',
                value: order.dropOff!.formatted,
              ),
            if (order.description.isNotEmpty)
              _InfoSection(
                icon: Icons.notes,
                label: 'Description',
                value: order.description,
              ),
            if (rider != null) ...[
              const Divider(height: 32),
              Text(
                'Rider',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: UserAvatar(user: rider!),
                title: Text(
                  rider!.name,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: Text(rider!.company?.name ?? 'Independent'),
                // trailing: Row(
                //   mainAxisSize: MainAxisSize.min,
                //   children: [
                //     // IconButton(
                //     //   icon: const Icon(Icons.location_on_outlined),
                //     //   onPressed: () {},
                //     // ),
                //     IconButton(
                //       icon: const Icon(Icons.chat_bubble_outline),
                //       onPressed: () {},
                //     ),
                //   ],
                // ),
              ),
            ],
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _InfoSection(
                  icon: Icons.category_outlined,
                  label: 'Type',
                  value: order.type.label,
                ),
                _InfoSection(
                  icon: Icons.check_circle_outline,
                  label: 'Status',
                  value: order.status.label,
                ),
                _InfoSection(
                  icon: Icons.attach_money,
                  label: 'Price',
                  value: currencyFormatter.format(order.price),
                ),
              ],
            ),
            const Divider(height: 32),
            if (!order.status.isProcessing)
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.tertiary,
                  ),
                  icon: const Icon(Icons.cancel),
                  label: const Text('Cancel Order'),
                  onPressed: () {},
                ),
              )
            else if (rider != null)
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  icon: const Icon(Icons.message_outlined),
                  label: const Text('Message Rider'),
                  onPressed: () {},
                ),
              ),
            const SizedBox(height: 12),
            if (rider?.company != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.help_outline),
                  label: const Text('Contact Company'),
                  onPressed: () {},
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.help_outline),
                  label: const Text('Contact Support'),
                  onPressed: () {},
                ),
              ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Icon(icon, size: 20, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface.withAlpha(140),
                  ),
                ),
                const SizedBox(height: 2),
                Text(value, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
