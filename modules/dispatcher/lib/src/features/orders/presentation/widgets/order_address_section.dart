import 'package:flutter/material.dart';
import 'package:logistix_ux/logistix_ux.dart';
import 'package:shared/shared.dart';

class OrderAddressSection extends StatelessWidget {
  const OrderAddressSection({required this.order, super.key});
  final Order order;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(title: 'Delivery Details'),
        const SizedBox(height: BootstrapSpacing.md),
        if (order.pickupAddress?.isNotEmpty ?? false) ...[
          BootstrapInfoTile(
            icon: Icons.trip_origin_rounded,
            iconColor: LogistixColors.primary,
            title: 'Pickup',
            value: order.pickupAddress!,
            onTap: order.hasPickupPosition
                ? () => LogistixLauncher.openMap(order.pickupLat!, order.pickupLng!)
                : null,
          ),
          if (order.pickupPhone?.isNotEmpty ?? false)
            Padding(
              padding: const EdgeInsets.only(left: BootstrapSpacing.xxl),
              child: BootstrapInfoTile(
                icon: Icons.phone_rounded,
                iconColor: LogistixColors.primary,
                title: 'Call Sender',
                value: order.pickupPhone!,
                onTap: () => LogistixLauncher.callNumber(order.pickupPhone!),
              ),
            ),
          const SizedBox(height: BootstrapSpacing.sm),
        ],
        BootstrapInfoTile(
          icon: Icons.flag_rounded,
          iconColor: Colors.orange,
          title: 'Drop-off',
          value: order.dropOffAddress,
          isBold: true,
          onTap: order.hasDropOffPosition
              ? () => LogistixLauncher.openMap(order.dropOffLat!, order.dropOffLng!)
              : null,
        ),
        if (order.dropOffPhone?.isNotEmpty ?? false)
          Padding(
            padding: const EdgeInsets.only(left: BootstrapSpacing.xxl),
            child: BootstrapInfoTile(
              icon: Icons.phone_forwarded_rounded,
              iconColor: Colors.orange,
              title: 'Call Receiver',
              value: order.dropOffPhone!,
              onTap: () => LogistixLauncher.callNumber(order.dropOffPhone!),
            ),
          ),
        const SizedBox(height: BootstrapSpacing.md),
        BootstrapInfoTile(
          icon: Icons.payments_rounded,
          iconColor: Colors.green,
          title: 'COD',
          value: order.codAmount != null && order.codAmount! > 0 ? '₦${order.codAmount!.toStringAsFixed(0)}' : 'None',
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: context.textTheme.labelMedium?.copyWith(
        fontWeight: FontWeight.w900,
        color: LogistixColors.textTertiary,
        letterSpacing: 1,
      ),
    );
  }
}
