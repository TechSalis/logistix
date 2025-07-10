import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logistix/core/utils/extensions/coordinates_extension.dart';
import 'package:logistix/core/utils/router.dart';
import 'package:logistix/features/location_core/domain/entities/coordinate.dart';
import 'package:logistix/features/map/application/marker_animator_rp.dart';
import 'package:logistix/features/rider/application/track_rider_rp.dart';
import 'package:logistix/app/domain/entities/rider_data.dart';

mixin TrackRiderControllerMixin<T extends ConsumerStatefulWidget>
    on ConsumerState<T>, SingleTickerProviderStateMixin<T>, RouteAware {
  late MarkerAnimator animator;
  GoogleMapController? map;
  bool isRouteActive = true;

  bool get followMarkerState;
  RiderData get rider;

  @protected
  RouteObserver<PageRoute<dynamic>> get observer => routeObserver;

  @override
  void didPushNext() {
    isRouteActive = false;
  }

  @override
  void didPopNext() {
    isRouteActive = true;
    final coords = ref.read(trackRiderProvider(rider)).value;
    if (coords != null) {
      map?.moveCamera(CameraUpdate.newLatLng(coords.toPoint()));
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    animator = ref.read(
      markerAnimatorProvider(
        MarkerAnimatorParams(
          vsync: this,
          initialPosition: ref.read(trackRiderProvider(rider)).value,
        ),
      ).notifier,
    );
    subscribeRouteAware();
  }

  @override
  void dispose() {
    animator.dispose();
    unsubscribeRouteAware();
    map = null;
    super.dispose();
  }

  void onRiderUpdate(Coordinates coords) {
    animator.updatePosition(coords);
    if (followMarkerState) {
      map?.animateCamera(
        CameraUpdate.newLatLng(coords.toPoint()),
        duration: kMapStreamPeriodDuration,
      );
    }
  }

  void subscribeRouteAware() {
    final route = ModalRoute.of(context);
    if (route is PageRoute) observer.subscribe(this as RouteAware, route);
  }

  void unsubscribeRouteAware() {
    observer.unsubscribe(this as RouteAware);
  }

  void listenToRiderTracking(WidgetRef ref) {
    if (isRouteActive) {
      ref.listen(trackRiderProvider(rider), (p, n) {
        if (n.hasValue) onRiderUpdate(n.requireValue);
      });
    }
  }
}
