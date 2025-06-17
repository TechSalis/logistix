import 'package:blur/blur.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:logistix/core/utils/extensions/context_extension.dart';
import 'package:logistix/features/map/presentation/widgets/map_box_view.dart';
import 'package:logistix/features/permission/presentation/logic/permission_rp.dart';
import 'package:logistix/features/permission/presentation/widgets/permission_dialog.dart';
import 'package:permission_handler/permission_handler.dart';

class MapSection extends ConsumerWidget {
  const MapSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          data: (data) {
            if (data.isGranted) return MapViewWidget();

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
                        onPressed: Geolocator.openLocationSettings,
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
