import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:logistix/core/utils/extensions/colors_extension.dart';
import 'package:logistix/core/utils/extensions/context_extension.dart';
import 'package:logistix/core/utils/extensions/coordinates_extension.dart';
import 'package:logistix/features/map/application/user_location_rp.dart';
import 'package:logistix/features/map/presentation/widgets/google_map_widget.dart';
import 'package:logistix/features/permission/application/permission_rp.dart';
import 'package:logistix/features/permission/presentation/widgets/permission_dialog.dart';

class UserMapView extends ConsumerStatefulWidget {
  const UserMapView({super.key, this.onCameraIdle, this.onMapCreated});

  final void Function(GoogleMapController map)? onCameraIdle;
  final void Function(GoogleMapController map)? onMapCreated;

  @override
  ConsumerState<UserMapView> createState() => _MapSectionState();
}

class _MapSectionState extends ConsumerState<UserMapView> {
  GoogleMapController? map;

  @override
  Widget build(BuildContext context) {
    // Fetch location permission state and show friendly permission
    // request dialog for user to accept or cancel
    ref.listen(permissionProvider(PermissionData.location), (previous, next) {
      if (next.hasValue && !next.value!.isGranted) {
        showDialog(
          context: context,
          barrierDismissible: false,
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
    return ref
        .watch(permissionProvider(PermissionData.location))
        .maybeWhen(
          orElse: SizedBox.new,
          data: (permission) {
            if (permission.isGranted) {
              return Stack(
                children: [
                  MapViewWidget(
                    markers: {
                      if (ref.watch(locationProvider)?.coordinates != null)
                        Marker(
                          markerId: const MarkerId('user_location'),
                          position:
                              ref
                                  .watch(locationProvider)!
                                  .coordinates!
                                  .toPoint(),
                          icon: BitmapDescriptor.defaultMarkerWithHue(
                            Theme.of(context).colorScheme.tertiary.toHue(),
                          ),
                        ),
                    },
                    onMapCreated: (m) async {
                      final provider = ref.read(locationProvider.notifier);
                      centerUserHelperFunction(map = m, provider);
                      provider.trackUserCoordinates();
                      widget.onMapCreated?.call(m);
                    },
                    onCameraIdle: () => widget.onCameraIdle?.call(map!),
                  ),
                ],
              );
            }
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
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Access to your Location is required.',
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    if (permission.status?.isPermanentlyDenied ?? false)
                      TextButton(
                        onPressed:
                            ref.read(locationSettingsProvider).openSettings,
                        style: TextButton.styleFrom(
                          textStyle: const TextStyle(fontSize: 18),
                        ),
                        child: const Text('Open Settings'),
                      )
                    else
                      TextButton(
                        onPressed:
                            ref
                                .read(
                                  permissionProvider(
                                    PermissionData.location,
                                  ).notifier,
                                )
                                .requestPermission,
                        style: TextButton.styleFrom(
                          textStyle: const TextStyle(fontSize: 18),
                        ),
                        child: const Text('Allow'),
                      ),
                  ],
                ),
              ],
            );
          },
        );
  }
}

Future<UserLocationNotifier> centerUserHelperFunction(
  GoogleMapController map,
  UserLocationNotifier provider,
) async {
  final pos = await provider.getUserCoordinates();
  map.animateCamera(CameraUpdate.newLatLng(pos.toPoint()));
  return provider;
}
