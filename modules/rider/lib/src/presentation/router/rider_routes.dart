import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:go_router/go_router.dart';
import 'package:rider/src/features/map/presentation/view/rider_map_tab.dart';
import 'package:rider/src/features/orders/presentation/view/rider_orders_tab.dart';
import 'package:rider/src/features/profile/presentation/view/rider_profile_tab.dart';
import 'package:rider/src/presentation/pages/rider_order_details_page.dart';
import 'package:rider/src/presentation/pages/rider_page.dart';
import 'package:shared/shared.dart';

/// Private relative route paths (without parent prefix)
abstract class _RiderPaths {
  static const String map = 'map';
  static const String orders = 'orders';
  static const String profile = 'profile';
}

/// Public rider module route paths (with /rider prefix)
abstract class RiderRoutes {
  static const String rootPath = ModuleRoutePaths.rider;

  static const String map = '$rootPath/${_RiderPaths.map}';

  static const String orders = '$rootPath/${_RiderPaths.orders}';

  static String orderDetails(String id) => '$orders/$id';

  static const String profile = '$rootPath/${_RiderPaths.profile}';
}

/// Rider module route configuration using StatefulShellRoute
@internal
List<RouteBase> get riderRoutes => [
  StatefulShellRoute.indexedStack(
    builder: (context, state, navigationShell) {
      return RiderPage(navigationShell: navigationShell);
    },
    branches: [
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: _RiderPaths.map,
            builder: (context, state) => const RiderMapTab(),
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: _RiderPaths.orders,
            builder: (context, state) => const RiderOrdersTab(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  final initialOrder = state.extra as Order?;
                  return RiderOrderDetailsPage(
                    orderId: id,
                    initialOrder: initialOrder,
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
            path: _RiderPaths.profile,
            builder: (context, state) => const RiderProfileTab(),
          ),
        ],
      ),
    ],
  ),
];
