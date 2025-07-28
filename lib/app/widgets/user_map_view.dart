import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logistix/core/utils/extensions/widget_extensions.dart';
import 'package:logistix/features/map/application/user_location_rp.dart';
import 'package:logistix/features/map/presentation/controllers/map_controller.dart';
import 'package:logistix/features/map/presentation/widgets/flutter_map_widget.dart';
import 'package:logistix/features/permission/application/permission_rp.dart';
import 'package:logistix/features/permission/domain/entities/permission_data.dart';
import 'package:logistix/features/permission/presentation/widgets/base_permission_dialog.dart';
import 'package:permission_handler/permission_handler.dart';

class UserMapView extends ConsumerWidget {
  const UserMapView({super.key, this.onMapCreated});
  final void Function(MyMapController map)? onMapCreated;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permission = permissionProvider(PermissionData.location);
    ref.listen(permission, (p, n) {
      if (n.canShowDialog()) {
        final ref = ProviderScope.containerOf(context);
        Future.delayed(Durations.long2, () {
          if (!context.mounted) return;
          showDialog(
            context: context,
            builder: (_) {
              return PermissionDisclosureDialog(
                data: PermissionData.location,
                openSettingsCallback: () {
                  ref.read(locationSettingsProvider).open();
                },
              );
            },
          );
        });
      }
    });
    final permissionState = ref.watch(permission);
    if (permissionState.isGranted == null) {
      return const SizedBox.shrink();
    } else if (permissionState.isGranted!) {
      return _buildMap(context, ref);
    } else {
      return const _PermissionDeniedOverlay();
    }
  }

  Widget _buildMap(BuildContext context, WidgetRef ref) {
    final userCoordinates = ref.watch(locationProvider)?.coordinates;
    return MapViewWidget(
      liteModeEnabled: true,
      onMapCreated: onMapCreated,
      initialPosition: userCoordinates,
      markers: [
        if (userCoordinates != null)
          Marker(
            key: const ValueKey('user_location'),
            point: userCoordinates.toPoint(),
            width: 42,
            height: 42,
            child: Transform.translate(
              offset: const Offset(0, -20),
              child: const MyLocationPin(size: 42),
            ),
          ),
      ],
    );
  }
}

class MyLocationPin extends StatelessWidget {
  const MyLocationPin({super.key, required this.size});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.location_pin,
      size: size,
      color: Theme.of(context).colorScheme.tertiary,
    );
  }
}

class _PermissionDeniedOverlay extends ConsumerWidget {
  const _PermissionDeniedOverlay();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPermanentlyDenied =
        ref
            .watch(permissionProvider(PermissionData.location))
            .status
            ?.isPermanentlyDenied ??
        false;

    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
            child: Image.asset(
              'assets/images/map_thumbnail.jpeg',
              fit: BoxFit.cover,
              color: context.isDarkTheme ? Colors.black54 : null,
              colorBlendMode: BlendMode.multiply,
            ),
          ),
        ),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Access to your location is required.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  if (isPermanentlyDenied) {
                    ref.read(locationSettingsProvider).open();
                  } else {
                    ref
                        .read(
                          permissionProvider(PermissionData.location).notifier,
                        )
                        .request();
                  }
                },
                child: Text(isPermanentlyDenied ? 'Open Settings' : 'Allow'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
