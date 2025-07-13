import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:logistix/core/theme/extensions/colors_extension.dart';
import 'package:logistix/core/theme/extensions/context_extension.dart';
import 'package:logistix/core/utils/extensions/coordinates_extension.dart';
import 'package:logistix/features/map/application/user_location_rp.dart';
import 'package:logistix/features/map/presentation/widgets/google_map_widget.dart';
import 'package:logistix/features/permission/application/permission_rp.dart';
import 'package:logistix/features/permission/presentation/widgets/permission_dialog.dart';

class UserMapView extends ConsumerWidget {
  const UserMapView({super.key, this.onMapCreated});

  final void Function(GoogleMapController map)? onMapCreated;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(permissionProvider(PermissionData.location), (p, n) {
      if (n.hasValue && !n.value!.isGranted) {
        showDialog(
          context: context,
          builder: (_) {
            return PermissionDisclosureDialog(
              data: PermissionData.location,
              openSettingsCallback: () {
                ref.read(locationSettingsProvider).openSettings();
              },
            );
          },
        );
      }
    });
    final permission = ref.watch(permissionProvider(PermissionData.location));
    return permission.maybeWhen(
      data: (status) {
        return status.isGranted
            ? _buildMap(context, ref)
            : const _PermissionDeniedOverlay();
      },
      orElse: () => const SizedBox.shrink(),
    );
  }

  Widget _buildMap(BuildContext context, WidgetRef ref) {
    final userCoordinates = ref.watch(locationProvider)?.coordinates;
    return MapViewWidget(
      liteModeEnabled: true,
      markers: {
        if (userCoordinates != null)
          Marker(
            markerId: const MarkerId('user_location'),
            position: userCoordinates.toPoint(),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              Theme.of(context).colorScheme.tertiary.toHue(),
            ),
          ),
      },
      onMapCreated: (controller) async {
        if (context.mounted) onMapCreated?.call(controller);
        final provider = ref.read(locationProvider.notifier)
          ..trackUserCoordinates();

        final pos = await provider.getUserCoordinatesUsecase();
        controller.animateCamera(CameraUpdate.newLatLng(pos.toPoint()));
      },
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
            .value
            ?.status
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
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  if (isPermanentlyDenied) {
                    ref.read(locationSettingsProvider).openSettings();
                  } else {
                    ref
                        .read(
                          permissionProvider(PermissionData.location).notifier,
                        )
                        .requestPermission();
                  }
                },
                style: TextButton.styleFrom(
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: Text(isPermanentlyDenied ? 'Open Settings' : 'Allow'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
