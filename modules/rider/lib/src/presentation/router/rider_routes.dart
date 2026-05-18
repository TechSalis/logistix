import 'package:go_router/go_router.dart';
import 'package:rider/src/features/map/presentation/view/rider_map_tab.dart';
import 'package:rider/src/features/deliveries/presentation/view/rider_deliveries_tab.dart';
import 'package:rider/src/features/profile/presentation/view/rider_account_page.dart';
import 'package:rider/src/features/profile/presentation/view/rider_profile_tab.dart';
import 'package:rider/src/presentation/pages/rider_delivery_details_page.dart';
import 'package:rider/src/presentation/pages/rider_page.dart';
import 'package:shared/shared.dart';

/// Private relative route paths (without parent prefix)
abstract class _RiderPaths {
  static const String map = 'map';
  static const String deliveries = 'deliveries';
  static const String profile = 'profile';
  static const String account = 'account';
}

/// Public rider module route paths (with /rider prefix)
abstract class RiderRoutes {
  static const String rootPath = ModuleRoutePaths.rider;

  static const String map = '$rootPath/${_RiderPaths.map}';

  static const String deliveries = '$rootPath/${_RiderPaths.deliveries}';

  static String deliveryDetails(String id) => '$deliveries/$id';

  static const String profile = '$rootPath/${_RiderPaths.profile}';
  static const String account = '$profile/account';
}

/// Rider module route configuration using StatefulShellRoute
List<RouteBase> get riderRoutes => [
  StatefulShellRoute.indexedStack(
    builder: (context, state, navigationShell) {
      return RiderPage(navigationShell: navigationShell);
    },
    branches: [
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: RiderRoutes.map,
            builder: (context, state) => const RiderMapTab(),
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: RiderRoutes.deliveries,
            builder: (context, state) => const RiderDeliveriesTab(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  final initialDelivery = state.extra as Delivery?;
                  return RiderDeliveryDetailsPage(
                    deliveryId: id,
                    initialDelivery: initialDelivery,
                  );
                },
              ),
            ],
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: RiderRoutes.profile,
            builder: (context, state) => const RiderProfileTab(),
            routes: [
               GoRoute(
                 path: _RiderPaths.account,
                 builder: (context, state) {
                  final rider = state.extra! as Rider;
                    return RiderAccountPage(rider: rider);
                 },
               ),
            ],
          ),
        ],
      ),
    ],
  ),
];
