import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logistix/core/utils/extensions/coordinates_extension.dart';
import 'package:logistix/features/map/application/marker_animator_rp.dart';
import 'package:logistix/features/map/presentation/widgets/google_map_widget.dart';
import 'package:logistix/features/rider/application/track_rider_rp.dart';
import 'package:logistix/core/entities/rider_data.dart';
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
  final void Function(GoogleMapController)? onMapCreated;

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
        m.moveCamera(
          CameraUpdate.newLatLng(
            ref.read(trackRiderProvider(widget.rider)).requireValue.toPoint(),
          ),
        );
        widget.onMapCreated?.call(m);
      },
      markers: {
        if (coordinates != null)
          Marker(
            markerId: MarkerId(widget.rider.id),
            position: coordinates.toPoint(),
            icon: AssetMapBitmap(
              'assets/images/delivery_location.png',
              imagePixelRatio: .8,
            ),
          ),
      },
    );
  }
}
