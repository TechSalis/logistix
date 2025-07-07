import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logistix/features/auth/domain/entities/user_data.dart';
import 'package:logistix/features/chat/presentation/pages/chat_page.dart';
import 'package:logistix/features/app/presentation/home_page.dart';
import 'package:logistix/features/location_picker/presentation/pages/location_picker_page.dart';
import 'package:logistix/features/order_now/delivery/presentation/pages/new_delivery_page.dart';
import 'package:logistix/features/order_now/food/presentation/pages/food_order_page.dart';
import 'package:logistix/core/entities/rider_data.dart';
import 'package:logistix/features/rider/presentation/pages/rider_tracker_page.dart';

part 'router.g.dart';


final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

final router = GoRouter(observers: [routeObserver], routes: $appRoutes);

@TypedGoRoute<HomePageRoute>(
  path: '/',
  routes: [
    TypedGoRoute<FoodOrderPageRoute>(path: 'food'),
    TypedGoRoute<NewDeliveryPageRoute>(path: 'delivery'),
    TypedGoRoute<ChatPageRoute>(path: 'chat'),
    TypedGoRoute<RiderTrackerPageRoute>(path: 'track-rider'),
  ],
)
class HomePageRoute extends GoRouteData with _$HomePageRoute {
  const HomePageRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const HomePage();
}

class FoodOrderPageRoute extends GoRouteData with _$FoodOrderPageRoute {
  const FoodOrderPageRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const FoodOrderPage();
}

class NewDeliveryPageRoute extends GoRouteData with _$NewDeliveryPageRoute {
  const NewDeliveryPageRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const NewDeliveryPage();
}

class ChatPageRoute extends GoRouteData with _$ChatPageRoute {
  const ChatPageRoute(this.$extra);
  final ChatParameters $extra;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      ChatPage(data: $extra);
}

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
