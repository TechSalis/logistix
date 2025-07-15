import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logistix/features/notifications/application/notification_service.dart';
import 'package:logistix/features/notifications/domain/entities/notification_data.dart';
import 'package:logistix/features/notifications/presentation/notifications/rider_found_notification_widget.dart';
import 'package:logistix/features/notifications/presentation/notifications/qa_rider_notification_widget.dart';
import 'package:logistix/features/permission/application/permission_rp.dart';
import 'package:logistix/features/permission/presentation/widgets/permission_dialog.dart';

class AppNotifications extends ConsumerWidget {
  const AppNotifications({super.key, required this.data});
  final AppNotificationData data;

  static void show(AppNotificationData data, {Duration? duration}) {
    NotificationService.inApp.show(data, duration: duration);
  }

  static void dismiss({NotificationKey? key, AppNotificationData? data}) {
    NotificationService.inApp.dismiss(key: key, data: data);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!(ref
            .read(permissionProvider(PermissionData.notifications))
            .isGranted ??
        true)) {
      ref
          .read(permissionProvider(PermissionData.notifications).notifier)
          .request();
    }
    return switch (data) {
      QARiderNotification() => QARiderNotificationWidget(
        data: data as QARiderNotification,
      ),
      RiderFoundNotification() => RiderFoundNotificationWidget(
        data: data as RiderFoundNotification,
      ),
      _ => const SizedBox(),
    };
  }
}
