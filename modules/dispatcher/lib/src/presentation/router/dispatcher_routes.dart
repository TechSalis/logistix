import 'package:dispatcher/src/features/more/presentation/view/more_tab.dart';
import 'package:dispatcher/src/features/orders/presentation/modals/ai_order_parser.dart';
import 'package:dispatcher/src/features/orders/presentation/view/create_order_page.dart';
import 'package:dispatcher/src/features/orders/presentation/view/order_details_page.dart';
import 'package:dispatcher/src/features/orders/presentation/view/orders_tab.dart';
import 'package:dispatcher/src/features/riders/presentation/view/rider_details_page.dart';
import 'package:dispatcher/src/features/riders/presentation/view/riders_tab.dart';
import 'package:dispatcher/src/presentation/pages/dispatcher_page.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:go_router/go_router.dart';
import 'package:shared/shared.dart';

/// Private relative route paths (without parent prefix)
abstract class _DispatcherPaths {
  static const String orders = '/orders';
  static const String riders = '/riders';
  static const String more = '/more';
  static const String createOrder = '/create';
  static const String parseText = '/parse';
}

/// Public dispatcher module route paths (with /dispatcher prefix)
abstract class DispatcherRoutes {
  static const String rootPath = ModuleRoutePaths.dispatcher;

  static const String orders = '$rootPath${_DispatcherPaths.orders}';
  static String orderDetails(String id) => '$orders/$id';
  static const String createOrder = '$orders${_DispatcherPaths.createOrder}';
  static const String parseText = '$createOrder${_DispatcherPaths.parseText}';

  static const String riders = '$rootPath${_DispatcherPaths.riders}';
  static String riderDetails(String id) => '$riders/$id';

  static const String more = '$rootPath${_DispatcherPaths.more}';
}

/// Dispatcher module route configuration using StatefulShellRoute
@internal
List<RouteBase> get dispatcherRoutes => [
  StatefulShellRoute.indexedStack(
    builder: (_, _, navigationShell) {
      return DispatcherPage(navigationShell: navigationShell);
    },
    branches: [
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: _DispatcherPaths.orders,
            builder: (context, state) => const OrdersTab(),
            routes: [
              GoRoute(
                path: _DispatcherPaths.createOrder,
                builder: (context, state) => CreateOrderPage(),
                routes: [
                  GoRoute(
                    path: _DispatcherPaths.parseText,
                    pageBuilder: (context, state) {
                      final initialValue = state.extra as String?;
                      return CustomTransitionPage(
                        key: state.pageKey,
                        opaque: false,
                        barrierDismissible: true,
                        barrierColor: Colors.black54,
                        transitionsBuilder: (context, animation, _, child) {
                          return SlideTransition(
                            position: animation.drive(
                              Tween<Offset>(
                                begin: const Offset(0, 1),
                                end: Offset.zero,
                              ).chain(CurveTween(curve: Curves.easeOutQuart)),
                            ),
                            child: child,
                          );
                        },
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: AIOrderParserBottomSheet(
                            initialValue: initialValue,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              GoRoute(
                path: ':id',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return OrderDetailsPage(orderId: id);
                },
              ),
            ],
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: _DispatcherPaths.riders,
            builder: (context, state) => const RidersTab(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return RiderDetailsPage(riderId: id);
                },
              ),
            ],
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: _DispatcherPaths.more,
            builder: (context, state) => const MoreTab(),
          ),
        ],
      ),
    ],
  ),
];
