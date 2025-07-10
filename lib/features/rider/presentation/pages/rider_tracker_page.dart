import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logistix/core/utils/extensions/coordinates_extension.dart';
import 'package:logistix/features/map/presentation/widgets/user_pan_away_refocus_widget.dart';
import 'package:logistix/features/rider/application/track_rider_rp.dart';
import 'package:logistix/app/domain/entities/rider_data.dart';
import 'package:logistix/features/rider/presentation/widgets/rider_card_small.dart';
import 'package:logistix/features/rider/presentation/widgets/rider_tracker_widget.dart';

class RiderTrackerPage extends ConsumerStatefulWidget {
  const RiderTrackerPage({super.key, required this.rider});
  final RiderData rider;

  @override
  ConsumerState<RiderTrackerPage> createState() => _RiderTrackerPageState();
}

class _RiderTrackerPageState extends ConsumerState<RiderTrackerPage> {
  bool followMarkerState = true;
  GoogleMapController? map;

  Future _onFollowRider() async {
    final coords = ref.read(trackRiderProvider(widget.rider)).value;
    if (coords != null) {
      map?.animateCamera(
        CameraUpdate.newLatLng(coords.toPoint()),
        duration: Durations.medium1,
      );
      await Future.delayed(Durations.medium1);
      if (mounted) setState(() => followMarkerState = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        titleSpacing: 0,
        title: RiderCardSmall.transparent(rider: widget.rider),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: PanAwayListener(
              onPanAway: (value) => setState(() => followMarkerState = !value),
              child: RiderTrackerMapWidget(
                rider: widget.rider,
                followMarkerState: followMarkerState,
                onMapCreated: (m) => map = m,
              ),
            ),
          ),
          if (!followMarkerState)
            Positioned(
              right: 16,
              bottom: MediaQuery.of(context).viewPadding.bottom + 16,
              child: Consumer(
                builder: (context, ref, child) {
                  return IconButton(
                    onPressed: _onFollowRider,
                    style: IconButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.surface,
                      backgroundColor: Theme.of(context).colorScheme.onPrimary,
                    ),
                    icon: const Icon(Icons.my_location),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
