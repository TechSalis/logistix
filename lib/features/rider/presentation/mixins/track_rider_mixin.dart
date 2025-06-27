import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logistix/core/constants/global_instances.dart';
import 'package:logistix/core/utils/extensions/coordinates_extension.dart';
import 'package:logistix/core/utils/router.dart';
import 'package:logistix/features/location_core/domain/entities/coordinate.dart';
import 'package:logistix/features/map/application/marker_animator_rp.dart';
import 'package:logistix/features/rider/application/track_rider_rp.dart';
import 'package:logistix/features/rider/domain/entities/rider.dart';

mixin TrackRiderControllerMixin<T extends ConsumerStatefulWidget>
    on ConsumerState<T>, SingleTickerProviderStateMixin<T>, RouteAware {
  late MarkerAnimator animator;
  GoogleMapController? map;
  bool isRouteActive = true;
  
  bool get followMarkerState;
  Rider get rider;

  @protected
  RouteObserver<PageRoute<dynamic>> get observer => routeObserver;

  @override
  void didPushNext() => isRouteActive = false;

  @override
  void didPopNext() => isRouteActive = true;

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
    map?.animateCamera(
      CameraUpdate.newLatLng(coords.toPoint()),
      duration: kMapStreamPeriodDuration,
    );
  }

  void subscribeRouteAware() {
    final route = ModalRoute.of(context);
    if (route is PageRoute) observer.subscribe(this as RouteAware, route);
  }

  void unsubscribeRouteAware() {
    observer.unsubscribe(this as RouteAware);
  }

  void listenToRiderTracking(WidgetRef ref) {
    if (followMarkerState && isRouteActive) {
      ref.listen(trackRiderProvider(rider), (p, n) {
        if (n.hasValue) onRiderUpdate(n.requireValue);
      });
    }
  }
}
