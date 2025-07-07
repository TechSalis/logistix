import 'package:flutter/material.dart';
import 'package:logistix/features/orders/domain/entities/order.dart';
import 'package:logistix/features/orders/presentation/widgets/order_details_sheet.dart';
import 'package:logistix/features/order_now/widgets/order_icon.dart';
import 'package:logistix/features/rider/presentation/widgets/rider_card_small.dart';

class OrderCard extends StatelessWidget {
  const OrderCard({super.key, required this.order, this.eta});

  final Order order;
  final String? eta;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rider = order.rider;
    void showDetails() {
      showModalBottomSheet(
        context: context,
        showDragHandle: true,
        isScrollControlled: true,
        builder: (_) => OrderDetailsSheet(order: order),
      );
    }

    return DecoratedBox(
      decoration: ShapeDecoration(
        color: Theme.of(context).cardTheme.color,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: showDetails,
            borderRadius: const BorderRadius.all(Radius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  OrderIcon(size: 44, action: order.type),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (order.dropOff != null)
                          Text(
                            order.dropOff!.formatted,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.clip,
                            maxLines: 1,
                          ),
                        if (order.description.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              order.description,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.textTheme.bodySmall!.color!
                                    .withAlpha(200),
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              margin: const EdgeInsets.only(right: 6),
                              decoration: ShapeDecoration(
                                color: order.status.color,
                                shape: const CircleBorder(),
                              ),
                            ),
                            Text(
                              order.status.label,
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (rider != null) RiderCardSmall(rider: rider, eta: eta),
        ],
      ),
    );
  }
}
