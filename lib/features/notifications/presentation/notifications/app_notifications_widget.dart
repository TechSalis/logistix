import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logistix/features/notifications/domain/entities/notification_data.dart';
import 'package:logistix/features/notifications/presentation/notifications/rider_found_notification_widget.dart';
import 'package:logistix/features/notifications/presentation/notifications/qa_rider_notification_widget.dart';

class AppNotificationsWidget extends ConsumerWidget {
  const AppNotificationsWidget({super.key, required this.data});
  final AppNotificationData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return switch (data) {
      QARiderNotification() => QARiderNotificationWidget(
        data: data as QARiderNotification,
      ),
      RiderFoundNotification() => RiderFoundNotificationWidget(
        data: data as RiderFoundNotification,
      ),
      _ =>
        throw UnimplementedError(
          '${data.runtimeType} is not yet added to AppNotificationsWidget',
        ),
    };
  }
}
