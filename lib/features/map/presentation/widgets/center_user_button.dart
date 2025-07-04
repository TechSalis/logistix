import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logistix/core/utils/extensions/coordinates_extension.dart';
import 'package:logistix/features/map/application/user_location_rp.dart';

class CenterUserOnMapButton extends ConsumerWidget {
  const CenterUserOnMapButton({super.key, required this.map});
  final GoogleMapController map;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void centerUserHelperFunction() {
      final pos = ref.read(locationProvider)?.coordinates;
      map.animateCamera(CameraUpdate.newLatLng(pos!.toPoint()));
    }

    return IconButton(
      onPressed: centerUserHelperFunction,
      style: IconButton.styleFrom(
        foregroundColor: Theme.of(context).colorScheme.surface,
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      icon: const Icon(Icons.my_location),
    );
  }
}
