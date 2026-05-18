import 'package:flutter/material.dart';
import 'package:logistix_ux/logistix_ux.dart';
import 'package:shared/shared.dart';

class RiderMarkerOverlayCard extends StatelessWidget {
  const RiderMarkerOverlayCard({
    required this.isLocationSelected,
    required this.selectedDelivery,
    super.key,
  });

  final bool isLocationSelected;
  final Delivery? selectedDelivery;

  @override
  Widget build(BuildContext context) {
    if (isLocationSelected) {
      return Container(
        padding: const EdgeInsets.symmetric(
            horizontal: BootstrapSpacing.sm, vertical: BootstrapSpacing.sm),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(BootstrapRadii.lg),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(BootstrapSpacing.xs),
              decoration: BoxDecoration(
                color: LogistixColors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.my_location_rounded,
                color: LogistixColors.primary,
                size: 14,
              ),
            ),
            const SizedBox(width: BootstrapSpacing.sm),
            Text(
              'Your Location',
              style: context.textTheme.labelMedium?.bold.copyWith(
                color: LogistixColors.primary,
              ),
            ),
          ],
        ),
      );
    }

    if (selectedDelivery == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: BootstrapSpacing.sm, vertical: BootstrapSpacing.sm),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(BootstrapRadii.lg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(BootstrapSpacing.xs),
            decoration: BoxDecoration(
              color:
                  (selectedDelivery!.status == DeliveryStatus.EN_ROUTE
                      ? LogistixColors.success
                      : LogistixColors.warning)
                  .withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              selectedDelivery!.status == DeliveryStatus.EN_ROUTE
                  ? Icons.local_shipping_rounded
                  : Icons.location_on_rounded,
              color: selectedDelivery!.status == DeliveryStatus.EN_ROUTE
                  ? LogistixColors.success
                  : LogistixColors.warning,
              size: 14,
            ),
          ),
          const SizedBox(width: BootstrapSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Delivery #${selectedDelivery!.trackingNumber}',
                style: context.textTheme.labelSmall?.bold.copyWith(
                  letterSpacing: 0.5,
                  fontSize: 10,
                  color: LogistixColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                selectedDelivery!.status == DeliveryStatus.EN_ROUTE
                    ? 'Delivery in Progress'
                    : 'Pickup Point',
                style: context.textTheme.labelMedium?.bold.copyWith(
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
