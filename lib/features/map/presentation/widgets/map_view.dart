import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logistix/core/utils/extensions/colors.dart';
import 'package:logistix/core/utils/extensions/context_extension.dart';
import 'package:logistix/core/utils/extensions/coordinates.dart';
import 'package:logistix/features/map/presentation/logic/user_location_rp.dart';
import 'package:logistix/features/map/presentation/widgets/google_map_widget.dart';
import 'package:logistix/features/permission/presentation/logic/permission_rp.dart';
import 'package:logistix/features/permission/presentation/widgets/permission_dialog.dart';
import 'package:permission_handler/permission_handler.dart';

class MapView extends ConsumerStatefulWidget {
  const MapView({super.key, this.onCameraIdle, this.onMapCreated});

  final Function(GoogleMapController map)? onCameraIdle;
  final Function(GoogleMapController map)? onMapCreated;

  @override
  ConsumerState<MapView> createState() => _MapSectionState();
}

class _MapSectionState extends ConsumerState<MapView> {
  GoogleMapController? map;
  Marker? userMarker;

  Future centerUser(GoogleMapController map) async {
    final location =
        await ref.read(locationProvider.notifier).getUserCoordinates();
    await map.animateCamera(CameraUpdate.newLatLng(location.toPoint()));
  }

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
            return PermissionDisclosureDialog(data: PermissionData.location);
          },
        );
      }
    });
    return ref
        .watch(permissionProvider(PermissionData.location))
        .maybeWhen(
          orElse: () => SizedBox(),
          data: (permission) {
            // Get saved permisison status
            if (permission.isGranted) {
              ref.listen(locationProvider, (previous, next) {
                if (next?.coordinates != null &&
                    userMarker?.position != next!.coordinates!.toPoint()) {
                  setState(() {
                    userMarker = Marker(
                      markerId: const MarkerId('user_location'),
                      position: next.coordinates!.toPoint(),
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                        Theme.of(context).colorScheme.tertiary.toHue(),
                      ),
                    );
                  });
                }
              });
              return Stack(
                children: [
                  MapViewWidget(
                    markers: {if (userMarker != null) userMarker!},
                    onMapCreated: (m) {
                      widget.onMapCreated?.call(m);
                      centerUser(map = m);
                    },
                    onCameraIdle: () => widget.onCameraIdle?.call(map!),
                  ),
                  Positioned(
                    right: 16,
                    bottom: 48,
                    child: IconButton(
                      onPressed: () => centerUser(map!),
                      style: IconButton.styleFrom(shape: CircleBorder()),
                      icon: Icon(Icons.my_location),
                    ),
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
                    SizedBox(height: 24),

                    if (permission.status?.isPermanentlyDenied ?? false)
                      TextButton(
                        onPressed:
                            ref.read(locationProvider.notifier).openSettings,
                        style: TextButton.styleFrom(
                          textStyle: TextStyle(fontSize: 18),
                        ),
                        child: Text('Open Settings'),
                      )
                    else
                      TextButton(
                        onPressed: () {
                          ref
                              .read(
                                permissionProvider(
                                  PermissionData.location,
                                ).notifier,
                              )
                              .requestPermission();
                        },
                        style: TextButton.styleFrom(
                          textStyle: TextStyle(fontSize: 18),
                        ),
                        child: Text('Allow'),
                      ),
                  ],
                ),
              ],
            );
          },
        );
  }
}
