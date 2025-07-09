import 'package:flutter/material.dart';
import 'package:logistix/core/constants/global_instances.dart';
import 'package:logistix/core/presentation/theme/styling.dart';
import 'package:logistix/core/presentation/widgets/user_avatar.dart';
import 'package:logistix/features/orders/domain/entities/order.dart';

class OrderDetailsSheet extends StatelessWidget {
  const OrderDetailsSheet({super.key, required this.order});
  final Order order;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      top: false,
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
            const SizedBox(height: 20),
            if (order.rider != null) ...[
              const Divider(height: 32),
              Text(
                'Rider',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: UserAvatar(user: order.rider!),
                title: Text(
                  order.rider!.name,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: Text(order.rider!.company?.name ?? 'Independent'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.my_location),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.chat_bubble_outline),
                      onPressed: () {},
                    ),
                  ],
                ),
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
            if (order.rider?.company != null)
              Padding(
                padding: const EdgeInsets.only(top: 32),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.help_outline),
                    label: const Text('Contact Company'),
                    onPressed: () {},
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.only(top: 32),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.help_outline),
                    label: const Text('Contact Support'),
                    onPressed: () {},
                  ),
                ),
              ),
            const SizedBox(height: 16),
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
