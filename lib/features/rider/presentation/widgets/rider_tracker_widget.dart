import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logistix/features/map/application/marker_animator_rp.dart';
import 'package:logistix/features/map/presentation/controllers/map_controller.dart';
import 'package:logistix/features/map/presentation/widgets/flutter_map_widget.dart';
import 'package:logistix/features/rider/application/track_rider_rp.dart';
import 'package:logistix/features/home/domain/entities/rider_data.dart';
import 'package:logistix/features/rider/presentation/controllers/track_rider_mixin.dart';

class RiderTrackerMapWidget extends ConsumerStatefulWidget {
  const RiderTrackerMapWidget({
    super.key,
    required this.rider,
    this.followMarkerState = true,
    this.onMapCreated,
  });

  final RiderData rider;
  final bool followMarkerState;
  final void Function(MyMapController)? onMapCreated;

  @override
  ConsumerState<RiderTrackerMapWidget> createState() =>
      _RiderTrackerMapWidgetState();
}

class _RiderTrackerMapWidgetState extends ConsumerState<RiderTrackerMapWidget>
    with
        SingleTickerProviderStateMixin,
        RouteAware,
        TrackRiderControllerMixin<RiderTrackerMapWidget> {
  @override
  bool get followMarkerState => widget.followMarkerState;

  @override
  RiderData get rider => widget.rider;

  @override
  Widget build(BuildContext context) {
    listenToRiderTracking(ref);
    final coordinates = ref.watch(markerAnimatorProvider(animator.arg));
    return MapViewWidget(
      onMapCreated: (m) {
        map = m;
        m.animateTo(ref.read(trackRiderProvider(widget.rider)).requireValue);
        widget.onMapCreated?.call(m);
      },
      markers: [
        if (coordinates != null)
          Marker(
            key: ValueKey(widget.rider.id),
            point: coordinates.toPoint(),
            child: Icon(
              Icons.location_on,
              color: Theme.of(context).colorScheme.tertiary,
            ),
          ),
      ],
    );
  }
}
