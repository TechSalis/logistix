import 'package:flutter/material.dart';
import 'package:logistix_ux/logistix_ux.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shared/shared.dart';

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
    final statusColor = order.status.color;

    return RepaintBoundary(
      child: AnimatedScaleTap(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: BootstrapSpacing.xs),
          decoration: BoxDecoration(
            color: LogistixColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: LogistixColors.black.withValues(alpha: 0.03)),
            boxShadow: [
              BoxShadow(
                color: LogistixColors.black.withValues(alpha: 0.04),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Header (Status, Tracking, Time)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: BootstrapSpacing.md,
                  vertical: BootstrapSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: LogistixColors.background,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  border: Border(bottom: BorderSide(color: LogistixColors.black.withValues(alpha: 0.03))),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                           BoxShadow(color: statusColor.withValues(alpha: 0.4), blurRadius: 4, spreadRadius: 1),
                        ],
                      ),
                    ),
                    const SizedBox(width: BootstrapSpacing.sm),
                    Text(
                      '#${order.trackingNumber}',
                      style: context.textTheme.labelLarge?.bold.copyWith(color: LogistixColors.text),
                    ),
                    if (order.companyId == null) ...[
                      const SizedBox(width: BootstrapSpacing.xs),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: LogistixColors.secondary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'APP',
                          style: context.textTheme.labelSmall?.bold.copyWith(color: LogistixColors.white, fontSize: 9),
                        ),
                      ),
                    ],
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: BootstrapSpacing.sm, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        order.status.label,
                        style: context.textTheme.labelSmall?.bold.copyWith(color: statusColor, fontSize: 10),
                      ),
                    ),
                  ],
                ),
              ),

              // Body (Timeline & Schedule)
              Padding(
                padding: const EdgeInsets.all(BootstrapSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (order.pickupAddress?.isNotEmpty ?? false)
                       _buildTimelineItem(context, 'Pickup', order.pickupAddress!, LucideIcons.mapPin, LogistixColors.primary, true),
                    if (order.pickupAddress?.isNotEmpty ?? false)
                       _buildTimelineDottedLine(),
                    _buildTimelineItem(context, 'Drop-off', order.dropOffAddress, LucideIcons.flag, LogistixColors.orange, false),

                    if (order.scheduledAt != null) ...[
                      const SizedBox(height: BootstrapSpacing.md),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: BootstrapSpacing.sm, vertical: BootstrapSpacing.xs),
                        decoration: BoxDecoration(
                          color: LogistixColors.primary.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: LogistixColors.primary.withValues(alpha: 0.1)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              LucideIcons.calendarClock,
                              size: 14,
                              color: LogistixColors.primary,
                            ),
                            const SizedBox(width: BootstrapSpacing.xs),
                            Text(
                              order.scheduledAt!.toScheduleString(),
                              style: context.textTheme.labelMedium?.bold.copyWith(color: LogistixColors.primary),
                            ),
                          ],
                        ),
                      ),
                    ],

                    if (action != null) ...[
                      const SizedBox(height: BootstrapSpacing.md),
                      Divider(color: LogistixColors.black.withValues(alpha: 0.05), height: 1),
                      const SizedBox(height: BootstrapSpacing.sm),
                      Align(alignment: Alignment.centerRight, child: action),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineItem(BuildContext context, String label, String address, IconData icon, Color color, bool isDimmed) {
     return Row(
       crossAxisAlignment: CrossAxisAlignment.start,
       children: [
         Container(
           margin: const EdgeInsets.only(top: 2),
           padding: const EdgeInsets.all(4),
           decoration: BoxDecoration(
             color: color.withValues(alpha: 0.1),
             shape: BoxShape.circle,
           ),
           child: Icon(icon, size: 12, color: color),
         ),
         const SizedBox(width: BootstrapSpacing.sm),
         Expanded(
           child: Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               Text(label, style: context.textTheme.labelSmall?.bold.copyWith(color: LogistixColors.textTertiary, fontSize: 10, letterSpacing: 0.5)),
               const SizedBox(height: 2),
               Text(
                 address,
                 style: context.textTheme.bodySmall?.copyWith(
                   color: isDimmed ? LogistixColors.textSecondary : LogistixColors.text,
                   fontWeight: isDimmed ? FontWeight.normal : FontWeight.w600,
                 ),
                 maxLines: 2,
                 overflow: TextOverflow.ellipsis,
               ),
             ],
           ),
         ),
       ],
     );
  }

  Widget _buildTimelineDottedLine() {
    return Padding(
      padding: const EdgeInsets.only(left: 9.5, top: 4, bottom: 4),
      child: Container(
        width: 1.5,
        height: 16,
        decoration: BoxDecoration(
          color: LogistixColors.textTertiary.withValues(alpha: 0.3),
        ),
      ),
    );
  }
}
