import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logistix/core/constants/global_instances.dart';
import 'package:logistix/core/utils/extensions/coordinates_extension.dart';
import 'package:logistix/features/map/presentation/widgets/google_map_widget.dart';
import 'package:logistix/features/rider/application/marker_animator_rp.dart';
import 'package:logistix/features/rider/application/track_rider_rp.dart';
import 'package:logistix/features/rider/domain/entities/rider.dart';
import 'package:logistix/features/rider/presentation/pages/rider_tracker_page.dart';
import 'package:logistix/features/rider/presentation/widgets/rider_card_small.dart';

class RiderOnTheWayCard extends StatelessWidget {
  const RiderOnTheWayCard({super.key, required this.rider, required this.eta});

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
class _RiderTrackerMapWidget extends ConsumerStatefulWidget {
  const _RiderTrackerMapWidget({required this.rider});
  final Rider rider;

  @override
  ConsumerState<_RiderTrackerMapWidget> createState() =>
      _RiderTrackerMapWidgetState();
}

class _RiderTrackerMapWidgetState extends ConsumerState<_RiderTrackerMapWidget>
    with SingleTickerProviderStateMixin {
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
        child: Consumer(
          builder: (context, ref, _) {
            ref.listen(trackRiderProvider(widget.rider), (p, n) {
              map?.animateCamera(
                CameraUpdate.newLatLng(n.requireValue.toPoint()),
                duration: kMapStreamPeriodDuration,
              );
            });
            final animator = ref.watch(
              markerAnimatorProvider(
                MarkerAnimatorParams(
                  vsync: this,
                  duration: kMapStreamPeriodDuration,
                  stream: trackRiderProvider(widget.rider),
                ),
              ),
            );
            return AbsorbPointer(
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
                  if (animator != null)
                    Marker(
                      markerId: MarkerId(widget.rider.id),
                      position: animator.toPoint(),
                    ),
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
