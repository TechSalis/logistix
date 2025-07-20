import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logistix/app/router/app_router.dart';
import 'package:logistix/features/location_core/domain/entities/coordinate.dart';
import 'package:logistix/features/map/application/marker_animator_rp.dart';
import 'package:logistix/features/map/presentation/controllers/map_controller.dart';
import 'package:logistix/features/rider/application/track_rider_rp.dart';
import 'package:logistix/features/home/domain/entities/rider_data.dart';

mixin TrackRiderControllerMixin<T extends ConsumerStatefulWidget>
    on ConsumerState<T>, SingleTickerProviderStateMixin<T>, RouteAware {
  late MarkerAnimator animator;
  MyMapController? map;
  bool isRouteActive = true;

  bool get followMarkerState;
  RiderData get rider;

  @protected
  RouteObserver<PageRoute<dynamic>> get observer => pageObserver;

  @override
  void didPushNext() => isRouteActive = false;

  @override
  void didPopNext() {
    isRouteActive = true;
    final coords = ref.read(trackRiderProvider(rider)).value;
    if (coords != null) map?.animateTo(coords);
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
    map?.dispose();
    unsubscribeRouteAware();
    super.dispose();
  }

  void onRiderUpdate(Coordinates coords) {
    animator.updatePosition(coords);
    if (followMarkerState) {
      map?.animateTo(coords, duration: kMapStreamPeriodDuration);
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
