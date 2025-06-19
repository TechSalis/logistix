import 'package:blur/blur.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:logistix/core/utils/extensions/context_extension.dart';
import 'package:logistix/features/map/presentation/logic/location_picker_rp.dart';
import 'package:logistix/features/home/presentation/widgets/map_box_view.dart';
import 'package:logistix/features/permission/presentation/logic/permission_rp.dart';
import 'package:logistix/features/permission/presentation/widgets/permission_dialog.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

class MapSection extends ConsumerWidget {
  const MapSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    MapboxMap? map;

    Future onCenterUser() async {
      final location =
          await ref.read(locationPickerProvider.notifier).getUserCoordinate();
      map?.easeTo(
        CameraOptions(
          pitch: 30,
          zoom: 15.5,
          center: Point(
            coordinates: Position(location.longitude, location.latitude),
          ),
        ),
        MapAnimationOptions(duration: 1000),
      );
    }

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
    if (ref.watch(permissionProvider(PermissionData.location)).hasValue) {
      final data =
          ref.watch(permissionProvider(PermissionData.location)).value!;
      if (data.isGranted) {
        return Stack(
          children: [
            MapViewWidget(
              onMapCreated: (m) {
                map = m;
                // final camera = await m.getCameraState();
                // m.setCamera(camera.toCameraOptions());
              },
              viewport: FollowPuckViewportState(pitch: 30, zoom: 15.5),
            ),
            Positioned(
              right: 16,
              bottom: 40.h,
              child: IconButton(
                onPressed: onCenterUser,
                style: IconButton.styleFrom(
                  elevation: 8,
                  shadowColor: Colors.black45,
                  foregroundColor: Theme.of(context).iconTheme.color,
                  backgroundColor: Theme.of(context).cardColor,
                  shape: CircleBorder(),
                ),
                icon: Icon(Icons.my_location),
              ),
            ),
          ],
        );
      }
      return Stack(
        fit: StackFit.expand,
        children: [
          if (context.isDarkTheme)
            Blur(
              blurColor: Theme.of(context).scaffoldBackgroundColor,
              colorOpacity: .7,
              child: Positioned.fill(
                child: Image.asset(
                  'assets/images/map_thumbnail.jpeg',
                  fit: BoxFit.cover,
                ),
              ),
            )
          else
            Blur(
              child: Positioned.fill(
                child: Image.asset(
                  'assets/images/map_thumbnail.jpeg',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Access to your Location is needed to use\nthe Map',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),

              if (data.status?.isPermanentlyDenied ?? false)
                TextButton(
                  onPressed:
                      ref.read(locationPickerProvider.notifier).openSettings,
                  child: Text('Open Settings'),
                )
              else
                TextButton(
                  onPressed: () {
                    ref
                        .read(
                          permissionProvider(PermissionData.location).notifier,
                        )
                        .requestPermission();
                  },
                  child: Text('Allow'),
                ),
            ],
          ),
        ],
      );
    }
    return SizedBox();
  }
}
