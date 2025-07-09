import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logistix/features/notifications/presentation/notifications/rider_found_notification_widget.dart';
import 'package:logistix/features/notifications/presentation/notifications/app_notifications_widget.dart';
import 'package:logistix/features/rider/application/find_rider_rp.dart';

class ProviderAppNotificationsHandler extends ConsumerWidget {
  const ProviderAppNotificationsHandler({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(findRiderProvider, (p, n) {
      if (n is RiderContactedState) {
        AppNotifications.show(RiderFoundNotification(rider: n.rider));
        // Reset rider dialog flow only if completed or cancelled
        Future.delayed(Durations.medium3, () {
          ref.invalidate(findRiderProvider);
        });
      }
    });
    return child;
  }
}
