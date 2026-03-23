import 'package:flutter/material.dart';
import 'package:logistix_ux/logistix_ux.dart';
import 'package:shared/shared.dart';
import 'package:timeago/timeago.dart' as timeago;

class OrderPreviewCard extends StatelessWidget {
  const OrderPreviewCard({
    required this.order,
    this.onTap,
    this.action,
    super.key,
  });

  final Order order;
  final VoidCallback? onTap;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final time = timeago.format(order.createdAt);
    final statusColor = order.status.color;

    return AnimatedScaleTap(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Status Indicator Bar
              Container(width: 6, color: statusColor),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              order.status.label.toUpperCase(),
                              style: context.textTheme.labelSmall?.bold
                                  .copyWith(color: statusColor, fontSize: 10),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '#${order.trackingNumber.toUpperCase()}',
                            style: context.textTheme.labelMedium?.bold.copyWith(
                              color: LogistixColors.textSecondary,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            time,
                            style: context.textTheme.labelSmall?.copyWith(
                              color: LogistixColors.textTertiary,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (order.pickupAddress?.isNotEmpty ?? false) ...[
                            LogistixInfoTile(
                              icon: Icons.trip_origin_rounded,
                              iconColor: LogistixColors.primary,
                              title: 'Pickup',
                              value: order.pickupAddress!,
                              fontSize: 13,
                              onTap: order.hasPickupPosition
                                  ? () => _openMap(
                                      order.pickupLat!,
                                      order.pickupLng!,
                                    )
                                  : null,
                            ),
                            const SizedBox(height: 4),
                          ],
                          LogistixInfoTile(
                            icon: Icons.flag_rounded,
                            iconColor: Colors.orange,
                            title: 'Drop-off',
                            value: order.dropOffAddress,
                            isBold: true,
                            fontSize: 13,
                            onTap: order.hasDropOffPosition
                                ? () => _openMap(
                                    order.dropOffLat!,
                                    order.dropOffLng!,
                                  )
                                : null,
                          ),
                        ],
                      ),
                      if (action != null) ...[
                        const SizedBox(height: 4),
                        Align(alignment: Alignment.centerRight, child: action),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openMap(double lat, double lng) {
    LauncherUtils.openMap(lat, lng);
  }
}
