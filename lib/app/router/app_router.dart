import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:logistix/app/providers/app_data_cache.dart';
import 'package:logistix/features/auth/domain/entities/user_data.dart';
import 'package:logistix/features/auth/infrastructure/repository/auth_local_store.dart';
import 'package:logistix/features/chat/presentation/pages/chat_page.dart';
import 'package:logistix/features/home/presentation/home_page.dart';
import 'package:logistix/features/location_picker/presentation/pages/location_picker_page.dart';
import 'package:logistix/features/order_now/delivery/presentation/pages/new_delivery_page.dart';
import 'package:logistix/features/order_now/food/presentation/pages/food_order_page.dart';
import 'package:logistix/features/home/domain/entities/rider_data.dart';
import 'package:logistix/features/orders/domain/entities/order.dart';
import 'package:logistix/features/orders/presentation/widgets/order_details_page.dart';
import 'package:logistix/features/rider/presentation/pages/rider_tracker_page.dart';

part 'app_router.g.dart';

final pageObserver = RouteObserver<PageRoute>();
final GoRouter router = GoRouter(
  observers: [pageObserver],
  restorationScopeId: 'app',
  routes: $appRoutes,
  redirect: (context, state) {
    final ref = ProviderScope.containerOf(context);
    if (!ref.read(appCacheProvider).isFirstLogin &&
        AuthLocalStore.instance.getSession() == null) {
      if (state.matchedLocation == '/') return '/auth';
    }
    return null;
  },
);

@TypedGoRoute<HomePageRoute>(
  path: '/',
  routes: [
    TypedGoRoute<FoodOrderPageRoute>(path: '/food'),
    TypedGoRoute<NewDeliveryPageRoute>(path: '/delivery'),
    TypedGoRoute<OrderDetailsPageRoute>(path: '/order-details'),
    TypedGoRoute<ChatPageRoute>(path: '/chat'),
    TypedGoRoute<RiderTrackerPageRoute>(path: '/rider-tracker'),
    TypedGoRoute<LocationPickerPageRoute>(path: '/location-picker'),
  ],
)
class HomePageRoute extends GoRouteData with _$HomePageRoute {
  const HomePageRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const HomePage();
}

@TypedGoRoute<FoodOrderPageRoute>(path: '/food')
class FoodOrderPageRoute extends GoRouteData with _$FoodOrderPageRoute {
  const FoodOrderPageRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const FoodOrderPage();
}

@TypedGoRoute<NewDeliveryPageRoute>(path: '/delivery')
class NewDeliveryPageRoute extends GoRouteData with _$NewDeliveryPageRoute {
  const NewDeliveryPageRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const NewDeliveryPage();
}

@TypedGoRoute<OrderDetailsPageRoute>(path: '/order-details')
class OrderDetailsPageRoute extends GoRouteData with _$OrderDetailsPageRoute {
  const OrderDetailsPageRoute(this.$extra);
  final Order $extra;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      OrderDetailsPage(order: $extra);
}

@TypedGoRoute<ChatPageRoute>(path: '/chat')
class ChatPageRoute extends GoRouteData with _$ChatPageRoute {
  const ChatPageRoute(this.$extra);
  final UserData $extra;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      ChatPage(user: $extra);
}

@TypedGoRoute<RiderTrackerPageRoute>(path: '/track-rider')
class RiderTrackerPageRoute extends GoRouteData with _$RiderTrackerPageRoute {
  const RiderTrackerPageRoute(this.$extra);
  final RiderData $extra;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      RiderTrackerPage(rider: $extra);
}

@TypedGoRoute<LocationPickerPageRoute>(path: '/location-picker')
class LocationPickerPageRoute extends GoRouteData
    with _$LocationPickerPageRoute {
  const LocationPickerPageRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const LocationPickerPage();
}
