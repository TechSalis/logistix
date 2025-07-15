import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:logistix/features/home/domain/entities/rider_data.dart';
import 'package:logistix/features/home/presentation/widgets/user_avatar.dart';
import 'package:logistix/core/theme/colors.dart';
import 'package:logistix/core/theme/styling.dart';
import 'package:logistix/features/location_core/domain/entities/address.dart';
import 'package:logistix/features/orders/domain/entities/order.dart';
import 'package:logistix/features/orders/presentation/widgets/order_details_sheet.dart';

enum OrderPopupEvent { cancel, reorder }

class EtaWidget extends StatelessWidget {
  const EtaWidget({super.key, required this.eta});
  final String? eta;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: "ETA: ",
        children: [
          TextSpan(
            text: eta ?? '--:--',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ],
        style: Theme.of(
          context,
        ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w400),
      ),
    );
  }
}

class OrderStatusChip extends StatelessWidget {
  final OrderStatus status;
  const OrderStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(status.label),
      visualDensity: const VisualDensity(vertical: -4),
      backgroundColor: status.color.withAlpha(30),
      shape: const LinearBorder(),
      labelStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
        fontWeight: FontWeight.w600,
        color: status.color,
      ),
    );
  }
}

class OrderRefNumberChip extends StatelessWidget {
  const OrderRefNumberChip({super.key, required this.order});
  final Order order;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      backgroundColor: AppColors.grey200,
      label: Row(
        children: [
          Text("#${order.refNumber}  "),
          const Icon(Icons.copy, size: 14),
        ],
      ),
      visualDensity: const VisualDensity(vertical: -4),
      onPressed: () {
        Clipboard.setData(ClipboardData(text: order.refNumber));
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Copied to clipboard")));
      },
    );
  }
}

class _LocationDisplay extends StatelessWidget {
  const _LocationDisplay({required this.location});
  final Address location;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Padding(
          padding: EdgeInsets.only(right: 6),
          child: Icon(Icons.location_on, size: 14),
        ),
        Expanded(
          child: Text(
            location.formatted,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class OrderCard extends StatelessWidget {
  const OrderCard({
    super.key,
    required this.order,
    this.onPopupSelected,
    this.rider,
  });

  final Order order;
  final RiderData? rider;
  final Function(OrderPopupEvent event)? onPopupSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          showDragHandle: true,
          isScrollControlled: true,
          builder: (context) {
            return OrderDetailsSheet(order: order, rider: order.rider);
          },
        );
      },
      child: Card(
      elevation: 1,
        child: Padding(
          padding: padding_16,
          child: RepaintBoundary(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(order.type.icon, color: order.type.color, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        order.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium!.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    OrderStatusChip(status: order.status),
                  ],
                ),
                const SizedBox(height: 12),
                DefaultTextStyle(
                  style: Theme.of(
                    context,
                  ).textTheme.labelMedium!.copyWith(fontWeight: FontWeight.w400),
                  child: Column(
                    children: [
                      if (order.pickUp != null)
                        _LocationDisplay(location: order.pickUp!),
                      if (order.pickUp != null && order.dropOff != null)
                        const SizedBox(height: 8),
                      if (order.dropOff != null)
                        _LocationDisplay(location: order.dropOff!),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                if (rider != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Divider(height: 24),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          RiderAvatar(user: rider!, radius: 14),
                          const SizedBox(width: 12),
                          Text(
                            rider!.name,
                            maxLines: 1,
                            style: theme.textTheme.labelLarge,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Spacer(),
                          const EtaWidget(eta: '40 min'),
                          // Text(
                          //   rider!.company?.name ?? 'Independent',
                          //   style: Theme.of(context).textTheme.bodySmall
                          //       ?.copyWith(fontWeight: FontWeight.w300),
                          //   overflow: TextOverflow.ellipsis,
                          //   maxLines: 1,
                          // ),
                        ],
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class OrderPreviewCard extends StatelessWidget {
  final Widget prefixTitle;
  final Order order;
  final Widget? etaWidget;
  final VoidCallback onViewOrder;

  const OrderPreviewCard({
    super.key,
    required this.prefixTitle,
    required this.order,
    this.etaWidget,
    required this.onViewOrder,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: padding_H16_V8,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 8.h),
            Row(
              children: [
                prefixTitle,
                OrderRefNumberChip(order: order),
                const Spacer(),
                OrderStatusChip(status: order.status),
              ],
            ),
            SizedBox(height: 8.h),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DefaultTextStyle(
                    style: Theme.of(context).textTheme.labelMedium!.copyWith(
                      fontWeight: FontWeight.w400,
                    ),
                    child: Row(
                      children: [
                        if (order.pickUp != null)
                          Expanded(
                            child: _LocationDisplay(location: order.pickUp!),
                          ),
                        if (order.pickUp != null && order.dropOff != null)
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Icon(
                              Icons.keyboard_double_arrow_right_outlined,
                              size: 20,
                            ),
                          ),
                        if (order.dropOff != null)
                          Expanded(
                            child: _LocationDisplay(location: order.dropOff!),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Flexible(
                    child: Text(
                      order.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w300,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 3,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (etaWidget != null) etaWidget!,
                // if (onTrack != null)
                //   Padding(
                //     padding: const EdgeInsets.only(right: 12),
                //     child: ElevatedButton.icon(
                //       onPressed: onTrack,
                //       icon: const Icon(Icons.location_pin),
                //       label: const Text("Track"),
                //       style: Theme.of(
                //         context,
                //       ).elevatedButtonTheme.style?.copyWith(
                //         iconSize: const WidgetStatePropertyAll(16),
                //         minimumSize: const WidgetStatePropertyAll(Size(0, 36)),
                //         textStyle: WidgetStatePropertyAll(
                //           Theme.of(context).textTheme.bodySmall,
                //         ),
                //         padding: const WidgetStatePropertyAll(
                //           EdgeInsets.symmetric(horizontal: 12),
                //         ),
                //       ),
                //     ),
                //   ),
                TextButton(
                  onPressed: onViewOrder,
                  style: Theme.of(context).textButtonTheme.style?.copyWith(
                    minimumSize: const WidgetStatePropertyAll(Size(0, 32)),
                    padding: const WidgetStatePropertyAll(padding_H12),
                  ),
                  child: const Text("View Order"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
