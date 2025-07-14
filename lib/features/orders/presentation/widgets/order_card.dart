import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:logistix/core/theme/colors.dart';
import 'package:logistix/core/theme/styling.dart';
import 'package:logistix/features/location_core/domain/entities/address.dart';
import 'package:logistix/features/orders/domain/entities/order.dart';
import 'package:logistix/features/orders/presentation/widgets/order_details_sheet.dart';

enum OrderPopupEvent { cancel, reorder }

class OrderCard extends StatelessWidget {
  const OrderCard({super.key, required this.order, this.onPopupSelected});

  final Order order;
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
        child: Padding(
          padding: padding_H16_V8,
          child: RepaintBoundary(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(order.type.icon, color: order.type.color, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        order.description,
                        maxLines: 1,
                        style: theme.textTheme.bodyMedium!.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                DefaultTextStyle(
                  style: Theme.of(
                    context,
                  ).textTheme.labelSmall!.copyWith(fontWeight: FontWeight.w400),
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
                Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 0),
                      child: _EtaWidget(eta: '40 mins'),
                    ),
                    const Spacer(),
                    OrderStatusChip(status: order.status),
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

class OrderStatusChip extends StatelessWidget {
  final OrderStatus status;
  const OrderStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(status.label),
      visualDensity: const VisualDensity(vertical: -4),
      backgroundColor: status.color.withAlpha(30),
      labelStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
        fontWeight: FontWeight.w600,
        color: status.color,
      ),
    );
  }
}

class LastOrderCard extends StatelessWidget {
  final Order order;
  final String? eta;
  final VoidCallback onViewDetails;

  const LastOrderCard({
    super.key,
    required this.order,
    required this.eta,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: padding_H16_V8,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                const Text("🕓", style: TextStyle(fontSize: 16)),
                Text(
                  " Last Order: ",
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                ActionChip(
                  backgroundColor: AppColors.grey200,
                  label: Row(
                    children: [
                      Text("#${order.id}  "),
                      const Icon(Icons.copy, size: 13),
                    ],
                  ),
                  visualDensity: const VisualDensity(vertical: -4),
                  onPressed: () {},
                ),
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
                    style: Theme.of(context).textTheme.labelSmall!.copyWith(
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
                  SizedBox(height: 4.h),
                  Flexible(
                    child: Text.rich(
                      TextSpan(
                        text: "Description: ",
                        children: [
                          TextSpan(
                            text: order.description * 2,
                            style: const TextStyle(fontWeight: FontWeight.w300),
                          ),
                        ],
                      ),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (eta != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 0),
                    child: _EtaWidget(eta: eta),
                  ),
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
                OutlinedButton(
                  onPressed: onViewDetails,
                  style: Theme.of(context).outlinedButtonTheme.style?.copyWith(
                    minimumSize: const WidgetStatePropertyAll(Size(0, 32)),
                    textStyle: WidgetStatePropertyAll(
                      Theme.of(context).textTheme.bodySmall,
                    ),
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

class _EtaWidget extends StatelessWidget {
  const _EtaWidget({required this.eta});
  final String? eta;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: "ETA:  ",
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
        ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
      ),
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
          child: Icon(Icons.location_on_outlined, size: 14),
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
