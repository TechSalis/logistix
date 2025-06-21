abstract class NotificationData {}

abstract class NotificationManager<T extends NotificationData> {
  showNotification();
  dismissNotification();
}
