import 'package:flutter/material.dart';
import 'package:logistix/core/presentation/theme/colors.dart';
import 'package:logistix/core/presentation/theme/styling.dart';
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
          builder: (context) => OrderDetailsSheet(order: order),
        );
      },
      child: Card(
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: RepaintBoundary(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            order.type.icon,
                            color: order.type.color,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              (order.pickUp ?? order.dropOff)?.formatted ??
                                  order.description,
                              maxLines: 1,
                              style: theme.textTheme.bodyMedium!.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        order.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall!.copyWith(
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          OrderStatusChip(status: order.status),
                          const SizedBox(width: 16),
                          if (order.rider != null)
                            RichText(
                              text: TextSpan(
                                text: 'Rider: ',
                                children: [
                                  TextSpan(
                                    text: order.rider!.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Theme(
                data: Theme.of(context).copyWith(
                  textButtonTheme: TextButtonThemeData(
                    style: TextButton.styleFrom(
                      textStyle: const TextStyle(fontWeight: FontWeight.w500),
                      foregroundColor: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                child: PopupMenuButton<OrderPopupEvent>(
                  padding: EdgeInsets.zero,
                  menuPadding: EdgeInsets.zero,
                  position: PopupMenuPosition.under,
                  shape: roundRectBorder8,
                  onSelected: onPopupSelected,
                  itemBuilder: (context) {
                    return [
                      if (!order.status.isFinal)
                        PopupMenuItem(
                          padding: const EdgeInsets.only(left: 12),
                          value: OrderPopupEvent.cancel,
                          enabled: order.status != OrderStatus.enRoute,
                          child: Text(
                            'Cancel Order',
                            style:
                                order.status == OrderStatus.enRoute
                                    ? null
                                    : const TextStyle(
                                      color: AppColors.redAccent,
                                    ),
                          ),
                        ),
                      if (order.status.isFinal)
                        const PopupMenuItem(
                          value: OrderPopupEvent.reorder,
                          child: Text('Repeat order'),
                        ),
                    ];
                  },
                ),
              ),
            ],
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
