import 'package:flutter/material.dart';
import 'package:logistix_ux/logistix_ux.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shared/shared.dart';

class DeliveryAddressSection extends StatelessWidget {
  const DeliveryAddressSection({required this.delivery, super.key});
  final Delivery delivery;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(title: 'Delivery Details'),
        const SizedBox(height: BootstrapSpacing.md),
        if (delivery.pickupAddress.isNotEmpty) ...[
          BootstrapInfoTile(
            icon: LucideIcons.mapPin,
            iconColor: LogistixColors.primary,
            title: 'Pickup',
            value: delivery.pickupAddress,
            onTap: delivery.hasPickupPosition
                ? () => LogistixLauncher.openMap(
                    delivery.pickupLat!,
                    delivery.pickupLng!,
                  )
                : null,
          ),
          if (delivery.pickupPhone?.isNotEmpty ?? false)
            Padding(
              padding: const EdgeInsets.only(left: BootstrapSpacing.xl),
              child: BootstrapInfoTile(
                icon: LucideIcons.phone,
                iconColor: LogistixColors.primary,
                title: 'Call Sender',
                value: delivery.pickupPhone!,
                onTap: () => LogistixLauncher.callNumber(delivery.pickupPhone!),
              ),
            ),
          const SizedBox(height: BootstrapSpacing.sm),
        ],
        BootstrapInfoTile(
          icon: LucideIcons.flag,
          iconColor: LogistixColors.orange,
          title: 'Drop-off',
          value: delivery.dropOffAddress,
          onTap: delivery.hasDropOffPosition
              ? () => LogistixLauncher.openMap(
                  delivery.dropOffLat!,
                  delivery.dropOffLng!,
                )
              : null,
        ),
        if (delivery.dropOffPhone?.isNotEmpty ?? false)
          Padding(
            padding: const EdgeInsets.only(left: BootstrapSpacing.xl),
            child: BootstrapInfoTile(
              icon: LucideIcons.phoneForwarded,
              iconColor: LogistixColors.orange,
              title: 'Call Receiver',
              value: delivery.dropOffPhone!,
              onTap: () => LogistixLauncher.callNumber(delivery.dropOffPhone!),
            ),
          ),
        const SizedBox(height: BootstrapSpacing.md),
        BootstrapInfoTile(
          icon: LucideIcons.banknote,
          iconColor: LogistixColors.green,
          title: 'COD',
          value: delivery.price != null && delivery.price! > 0
              ? '₦${delivery.price!.toStringAsFixed(0)}'
              : 'N/A',
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
