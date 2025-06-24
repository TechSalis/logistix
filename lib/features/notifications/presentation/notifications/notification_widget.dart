import 'package:flutter/material.dart';
import 'package:logistix/features/notifications/application/notification_service.dart';
import 'package:logistix/features/notifications/domain/entities/notification_data.dart';
import 'package:logistix/features/notifications/presentation/notifications/rider_found_notification_widget.dart';
import 'package:logistix/features/notifications/presentation/notifications/qa_rider_notification_widget.dart';

class AppNotifications extends StatelessWidget {
  const AppNotifications({super.key, required this.data});
  final AppNotificationData data;

  static final AppNotificationService _instance = AppNotificationService();

  static void show(AppNotificationData data, {Duration? duration}) =>
      _instance.show(data, duration: duration);

  static void dismiss({NotificationKey? key, AppNotificationData? data}) =>
      _instance.dismiss(key: key, data: data);

  @override
  Widget build(BuildContext context) {
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
