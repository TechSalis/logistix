import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logistix/core/constants/global_instances.dart';
import 'package:logistix/core/utils/extensions/coordinates_extension.dart';
import 'package:logistix/features/map/presentation/widgets/google_map_widget.dart';
import 'package:logistix/features/map/presentation/widgets/user_pan_away_refocus_widget.dart';
import 'package:logistix/features/rider/application/marker_animator_rp.dart';
import 'package:logistix/features/rider/application/track_rider_rp.dart';
import 'package:logistix/features/rider/domain/entities/rider.dart';
import 'package:logistix/features/rider/presentation/widgets/rider_card_small.dart';

class RiderTrackerPage extends ConsumerStatefulWidget {
  const RiderTrackerPage({super.key, required this.rider});
  final Rider rider;

  @override
  ConsumerState<RiderTrackerPage> createState() => _RiderTrackerPageState();
}

class _RiderTrackerPageState extends ConsumerState<RiderTrackerPage>
    with SingleTickerProviderStateMixin {
  GoogleMapController? map;
  bool followMarkerState = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: Colors.transparent,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Consumer(
              builder: (context, ref, child) {
                ref.listen(trackRiderProvider(widget.rider), (p, n) {
                  map?.animateCamera(
                    CameraUpdate.newLatLng(n.requireValue.toPoint()),
                    duration: kMapStreamPeriodDuration,
                  );
                });
                final coordinates = ref.watch(
                  markerAnimatorProvider(
                    MarkerAnimatorParams(
                      vsync: this,
                      stream: trackRiderProvider(widget.rider),
                    ),
                  ),
                );
                return MapPanUnfocusListener(
                  shouldFollowMarker: (followMarker) {
                    setState(() => followMarkerState = followMarker);
                  },
                  child: MapViewWidget(
                    onMapCreated: (m) {
                      map = m;
                      map?.animateCamera(
                        CameraUpdate.newLatLng(
                          ref
                              .read(trackRiderProvider(widget.rider))
                              .requireValue
                              .toPoint(),
                        ),
                        duration: kMapStreamPeriodDuration,
                      );
                    },
                    markers: {
                      if (coordinates != null)
                        Marker(
                          markerId: MarkerId(widget.rider.id),
                          position: coordinates.toPoint(),
                        ),
                    },
                  ),
                );
              },
            ),
          ),
          if (!followMarkerState)
            Positioned(
              right: 16,
              bottom: 140,
              child: Consumer(
                builder: (context, ref, child) {
                  return IconButton(
                    onPressed: () {
                      setState(() => followMarkerState = true);
                      map?.animateCamera(
                        CameraUpdate.newLatLng(
                          ref
                              .read(trackRiderProvider(widget.rider))
                              .requireValue
                              .toPoint(),
                        ),
                      );
                    },
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.my_location),
                  );
                },
              ),
            ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: SafeArea(child: RiderCardSmall(rider: widget.rider)),
          ),
        ],
      ),
    );
  }
}
