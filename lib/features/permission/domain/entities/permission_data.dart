
import 'package:permission_handler/permission_handler.dart';

class PermissionData {
  final Permission permission;
  final String name, description;

  const PermissionData({
    required this.permission,
    required this.name,
    required this.description,
  });

  static const location = PermissionData(
    permission: Permission.locationWhenInUse,
    name: 'Location',
    description:
        'To show available riders, estimate delivery time, and track your orders live, '
        'we need access to your device’s location.',
  );

  static const notifications = PermissionData(
    permission: Permission.notification,
    name: 'Notifications',
    description:
        'To receive updates and alerts, we need access to your device’s notifications.',
  );
}
