import 'package:flutter/material.dart';
import 'package:logistix_ux/logistix_ux.dart';
import 'package:shared/shared.dart';
import 'package:timeago/timeago.dart' as timeago;

class OrderPreviewCard extends StatelessWidget {
  const OrderPreviewCard({required this.order, this.onTap, super.key});

  final Order order;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final time = timeago.format(order.createdAt);
    final statusColor = order.status.color;

    return AnimatedScaleTap(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    order.status.value,
                    style: context.textTheme.labelSmall?.bold.copyWith(
                      color: statusColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Flexible(
                  child: Text(
                    '#${order.trackingNumber}',
                    maxLines: 1,
                    style: context.textTheme.labelSmall?.bold.copyWith(
                      color: LogistixColors.textTertiary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.trip_origin_rounded,
                  color: LogistixColors.primary,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    order.pickupAddress,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.bodyMedium?.semiBold.copyWith(
                      color: LogistixColors.text,
                    ),
                  ),
                ),
                if (order.codAmount != null) ...[
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'COD',
                        style: context.textTheme.labelSmall?.bold.copyWith(
                          color: LogistixColors.textSecondary,
                        ),
                      ),
                      Text(
                        '₩${order.codAmount!.toStringAsFixed(0)}',
                        style: context.textTheme.titleMedium?.bold.copyWith(
                          color: LogistixColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
            if (order.dropOffAddress != null) ...[
              const SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.flag_rounded,
                    color: LogistixColors.textTertiary,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      order.dropOffAddress!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: LogistixColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const Divider(
              thickness: 1,
              height: 32,
              color: LogistixColors.border,
            ),
            Row(
              children: [
                const Icon(
                  Icons.access_time_filled_rounded,
                  color: LogistixColors.textTertiary,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  time,
                  style: context.textTheme.bodySmall?.medium.copyWith(
                    color: LogistixColors.textTertiary,
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: LogistixColors.textTertiary,
                  size: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
