import 'package:flutter/material.dart';
import 'package:leak_tracker/leak_tracker.dart';
import 'package:logistix/features/location_core/domain/entities/address.dart';
import 'package:logistix/features/notifications/presentation/notifications/notification_widget.dart';
import 'package:logistix/features/notifications/presentation/notifications/qa_rider_notification_widget.dart';
import 'package:logistix/features/orders/domain/entities/order.dart';
import 'package:logistix/features/quick_actions/domain/quick_actions_types.dart';
import 'package:logistix/features/rider/domain/entities/rider.dart';

class DebugFloatingIcon extends StatelessWidget {
  const DebugFloatingIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton.small(
          heroTag: null,
          onPressed: () async {
            // LeakTracking.collectLeaks();
            final leaks = await LeakTracking.checkLeaks();
            print(leaks.toMessage());

            // AppNotifications.show(
            //   duration: Duration.zero,
            //   const QARiderNotification(
            //     rider: Rider(
            //       id: 'id',
            //       name: 'Abdul Dromonka',
            //       company: 'WiMart Logistics',
            //       rating: 4,
            //     ),
            //     order: Order(
            //       id: 'id',
            //       type: ActionType.delivery,
            //       pickUp: Address('pickUp'),
            //       dropOff: Address('dropOff'),
            //       price: 5000.03,
            //       status: OrderStatus.confirmed,
            //     ),
            //   ),
            // );
          },
          tooltip: 'Trigger test notification',
          child: const Icon(Icons.bug_report),
        ),
        FloatingActionButton.small(
          heroTag: null,
          onPressed: () async {
            AppNotifications.show(
              duration: Duration.zero,
              const QARiderNotification(
                rider: Rider(
                  id: 'id',
                  name: 'Abdul Dromonka',
                  company: 'WiMart Logistics',
                  rating: 4,
                ),
                order: Order(
                  id: 'id',
                  type: ActionType.delivery,
                  pickUp: Address('pickUp'),
                  dropOff: Address('dropOff'),
                  price: 5000.03,
                  status: OrderStatus.confirmed,
                ),
              ),
            );
          },
          tooltip: 'Trigger test notification',
          child: const Icon(Icons.bug_report),
        ),
      ],
    );
  }
}
