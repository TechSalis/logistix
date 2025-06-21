import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:logistix/features/permission/presentation/logic/permission_rp.dart';

class PermissionData {
  final PermissionWithService permission;
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
}

class PermissionDisclosureDialog extends ConsumerWidget {
  final PermissionData data;

  const PermissionDisclosureDialog({super.key, required this.data});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(permissionProvider(data), (previous, next) {
      switch (next.value?.status) {
        case PermissionStatus.granted:
          ref
              .read(permissionProvider(PermissionData.location).notifier)
              .setHasGranted();
        case PermissionStatus.permanentlyDenied:
          openAppSettings();
        default:
      }
      Navigator.of(context).pop();
    });
    final theme = Theme.of(context);
    return Dialog(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
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
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      ref
                          .read(permissionProvider(data).notifier)
                          .requestPermission();
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
