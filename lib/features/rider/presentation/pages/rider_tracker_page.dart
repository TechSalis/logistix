import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logistix/core/theme/styling.dart';
import 'package:logistix/core/utils/extensions/widget_extensions.dart';
import 'package:logistix/app/router/app_router.dart';
import 'package:logistix/features/map/presentation/widgets/user_pan_away_refocus_widget.dart';
import 'package:logistix/features/rider/application/track_rider_rp.dart';
import 'package:logistix/features/home/domain/entities/rider_data.dart';
import 'package:logistix/features/rider/presentation/widgets/rider_profile_group.dart';
import 'package:logistix/features/rider/presentation/widgets/rider_tracker_widget.dart';

class RiderTrackerPage extends ConsumerStatefulWidget {
  const RiderTrackerPage({super.key, required this.rider});
  final RiderData rider;

  @override
  ConsumerState<RiderTrackerPage> createState() => _RiderTrackerPageState();
}

class _RiderTrackerPageState extends ConsumerState<RiderTrackerPage> {
  bool? followMarkerState = true;
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface.withAlpha(0),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          PanAwayListener(
            enabled: followMarkerState == true,
            onPanAway: (value) => setState(() => followMarkerState = !value),
            child: RiderTrackerMapWidget(
              rider: widget.rider,
              followMarkerState: followMarkerState == true,
              onMapCreated: (m) => map = m,
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 48,
            child: RepaintBoundary(
              child: Column(
                children: [
                  if (followMarkerState == false)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Consumer(
                          builder: (context, ref, child) {
                            return IconButton(
                              onPressed: _onFollowRider,
                              style: IconButton.styleFrom(
                                foregroundColor:
                                    Theme.of(context).colorScheme.surface,
                                backgroundColor:
                                    Theme.of(context).colorScheme.onPrimary,
                              ),
                              icon: const Icon(Icons.my_location),
                            );
                          },
                        ),
                      ),
                    ),
                  Card(
                    elevation: 8,
                    child: Padding(
                      padding: padding_24,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: RiderProfileGroup(user: widget.rider),
                              ),
                              IconButton(
                                onPressed: () {},
                                padding: EdgeInsets.zero,
                                icon: const Icon(Icons.help_outline),
                                tooltip: 'Help',
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {},
                                  icon: const Icon(Icons.call),
                                  label: const Text('Call Rider'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    ChatPageRoute(widget.rider).push(context);
                                  },
                                  icon: const Icon(Icons.message_outlined),
                                  label: const Text('Message'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
