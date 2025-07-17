import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logistix/core/utils/extensions/widget_extensions.dart';
import 'package:logistix/features/map/application/user_location_rp.dart';
import 'package:logistix/features/map/presentation/widgets/google_map_widget.dart';
import 'package:logistix/features/permission/application/permission_rp.dart';
import 'package:logistix/features/permission/presentation/widgets/permission_dialog.dart';
import 'package:permission_handler/permission_handler.dart';

class UserMapView extends ConsumerWidget {
  const UserMapView({super.key, this.onMapCreated});

  final void Function(GoogleMapController map)? onMapCreated;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(
      permissionProvider(
        PermissionData.location,
      ).select((v) => v.status == null),
      (p, n) {
        if (n) {
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
        }
      },
    );
    final permission = ref.watch(permissionProvider(PermissionData.location));

    if (permission.isGranted == null) {
      return const SizedBox.shrink();
    } else if (permission.isGranted!) {
      return _buildMap(context, ref);
    } else {
      return const _PermissionDeniedOverlay();
    }
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
                // style: TextButton.styleFrom(
                //   textStyle: const TextStyle(fontSize: 18),
                // ),
                child: Text(isPermanentlyDenied ? 'Open Settings' : 'Allow'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
