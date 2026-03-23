import 'package:flutter/material.dart';
import 'package:logistix_ux/logistix_ux.dart';
import 'package:shared/shared.dart';

class RiderMarkerOverlayCard extends StatelessWidget {
  const RiderMarkerOverlayCard({
    required this.isLocationSelected,
    required this.selectedOrder,
    super.key,
  });

  final bool isLocationSelected;
  final Order? selectedOrder;

  @override
  Widget build(BuildContext context) {
    if (isLocationSelected) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
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
              padding: const EdgeInsets.all(6),
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
            const SizedBox(width: 10),
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

    if (selectedOrder == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: (selectedOrder!.status == OrderStatus.enRoute
                      ? LogistixColors.success
                      : LogistixColors.warning)
                  .withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              selectedOrder!.status == OrderStatus.enRoute
                  ? Icons.local_shipping_rounded
                  : Icons.location_on_rounded,
              color: selectedOrder!.status == OrderStatus.enRoute
                  ? LogistixColors.success
                  : LogistixColors.warning,
              size: 14,
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'ORDER #${selectedOrder!.trackingNumber.toUpperCase()}',
                style: context.textTheme.labelSmall?.bold.copyWith(
                  letterSpacing: 0.5,
                  fontSize: 10,
                  color: LogistixColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                selectedOrder!.status == OrderStatus.enRoute
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
