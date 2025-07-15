import 'package:logistix/features/notifications/domain/entities/notification_data.dart';
import 'package:logistix/features/notifications/presentation/notifications/app_notifications_widget.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

part 'fcm.dart';

abstract class NotificationService {
  static final inApp = _AppNotificationService();

  static Future<void> setup() => _setupFCM();
}

class _AppNotificationService {
  final Map<NotificationKey, OverlaySupportEntry> _activeOverlays = {};

  void show(AppNotificationData notification, {Duration? duration}) {
    final key = notification.key ?? NotificationKey(notification);
    final entry = showOverlayNotification(
      (context) => AppNotifications(data: notification),
      duration: duration,
      key: key,
    );

    _activeOverlays[key] = entry;

    entry.dismissed.then((_) {
      if (_activeOverlays.containsValue(entry)) {
        return _activeOverlays.remove(key)?.dismiss();
      }
    });
  }

  /// Either one of [NotificationKey? key] or [AppNotificationData? data] must be set
  void dismiss({NotificationKey? key, AppNotificationData? data}) {
    assert((key ?? data) != null);

    key ??= NotificationKey(data!);
    _activeOverlays.remove(key)?.dismiss();
  }
}
