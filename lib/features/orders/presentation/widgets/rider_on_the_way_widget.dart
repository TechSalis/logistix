import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logistix/core/utils/extensions/coordinates_extension.dart';
import 'package:logistix/features/map/presentation/widgets/google_map_widget.dart';
import 'package:logistix/features/rider/application/track_rider_rp.dart';
import 'package:logistix/features/rider/domain/entities/rider.dart';
import 'package:logistix/features/rider/presentation/pages/rider_tracker_page.dart';
import 'package:logistix/features/rider/presentation/widgets/rider_card_small.dart';

class RiderOnTheWayCard extends StatelessWidget {
  const RiderOnTheWayCard({
    super.key,
    required this.rider,
    required this.eta,
  });

  final Rider rider;
  final String eta;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            children: [
              _RiderTrackerMapWidget(rider: rider),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(100),
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.navigation,
                        size: 14,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Tracking Rider',
                        style: Theme.of(
                          context,
                        ).textTheme.labelSmall?.copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 8,
                right: 16,
                child: IgnorePointer(
                  child: Text(
                    'Tap to view',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
            ],
          ),
          RiderCardSmall(rider: rider, eta: eta),
        ],
      ),
    );
  }
}

// ignore: must_be_immutable
class _RiderTrackerMapWidget extends StatefulWidget {
  const _RiderTrackerMapWidget({required this.rider});
  final Rider rider;

  @override
  State<_RiderTrackerMapWidget> createState() => _RiderTrackerMapWidgetState();
}

class _RiderTrackerMapWidgetState extends State<_RiderTrackerMapWidget> {
  GoogleMapController? map;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => RiderTrackerPage(rider: widget.rider),
          ),
        );
      },
      child: SizedBox(
        height: 140,
        child: AbsorbPointer(
          child: Consumer(
            builder: (context, ref, child) {
              ref.listen(trackRiderProvider(widget.rider), (p, n) {
                if (n.hasValue) {
                  map?.animateCamera(
                    CameraUpdate.newLatLng(n.requireValue.toPoint()),
                  );
                }
              });
              return MapViewWidget(
                onMapCreated: (m) => map = m,
                markers: {
                  if (ref.watch(trackRiderProvider(widget.rider)).hasValue)
                    Marker(
                      markerId: const MarkerId('find_rider'),
                      position:
                          ref
                              .watch(trackRiderProvider(widget.rider))
                              .value!
                              .toPoint(),
                    ),
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
