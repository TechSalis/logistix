import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:logistix/core/theme/styling.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:logistix/features/permission/application/permission_rp.dart';

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
        'To show available riders, estimate delivery time, and track your order live, '
        'we need access to your device’s location.',
  );

  static const notifications = PermissionData(
    permission: Permission.notification,
    name: 'Notifications',
    description:
        'To receive updates and alerts, we need access to your device’s notifications.',
  );
}

class PermissionDisclosureDialog extends ConsumerWidget {
  final PermissionData data;
  final VoidCallback? openSettingsCallback;

  const PermissionDisclosureDialog({
    super.key,
    required this.data,
    this.openSettingsCallback,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(permissionProvider(data), (p, n) {
      if (n.status?.isPermanentlyDenied ?? false) {
        openSettingsCallback?.call();
      }
      if (n.isGranted != null) GoRouter.of(context).pop(true);
    });
    final theme = Theme.of(context);
    return Dialog(
      elevation: 4,
      shape: roundRectBorder16,
      child: Padding(
        padding: padding_24,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.location_on_rounded,
              color: theme.colorScheme.primary,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              '${data.name} Access Required',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              data.description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.hintColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                // Expanded(
                //   child: OutlinedButton(
                //     onPressed: () {
                //       ref
                //           .read(permissionProvider(data).notifier)
                //           .setHasGranted();
                //       Navigator.of(context).pop();
                //     },
                //     child: const Text('Cancel'),
                //   ),
                // ),
                // const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      ref.read(permissionProvider(data).notifier).request();
                    },
                    child: const Text('Continue'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
