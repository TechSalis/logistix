import 'package:bootstrap/interfaces/modules/modules.dart';
import 'package:dispatcher/src/features/chat/presentation/pages/chat_detail_page.dart';
import 'package:dispatcher/src/features/chat/presentation/pages/chats_tab.dart';
import 'package:dispatcher/src/features/more/presentation/view/account_page.dart';
import 'package:dispatcher/src/features/more/presentation/view/more_tab.dart';
import 'package:dispatcher/src/features/more/presentation/view/request_integration_page.dart';
import 'package:dispatcher/src/features/orders/presentation/modals/ai_order_parser.dart';
import 'package:dispatcher/src/features/orders/presentation/view/create_order_page.dart';
import 'package:dispatcher/src/features/orders/presentation/view/order_details_page.dart';
import 'package:dispatcher/src/features/orders/presentation/view/orders_tab.dart';
import 'package:dispatcher/src/features/riders/presentation/view/rider_details_page.dart';
import 'package:dispatcher/src/features/riders/presentation/view/riders_tab.dart';
import 'package:dispatcher/src/presentation/pages/dispatcher_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared/shared.dart';

/// Private relative route paths (without parent prefix)
abstract class _DispatcherPaths {
  static const String orders = 'orders';
  static const String chats = 'chats';
  static const String riders = 'riders';
  static const String more = 'more';
  static const String createOrder = 'create';
  static const String parseText = 'parse';
  static const String list = 'list';
  static const String map = 'map';
}

/// Public dispatcher module route paths (with /dispatcher prefix)
abstract class DispatcherRoutes {
  static const String rootPath = ModuleRoutePaths.dispatcher;

  static const String orders = '$rootPath/${_DispatcherPaths.orders}';
  static String orderDetails(String id) => '$orders/$id';

  static const String createOrder = '$orders/${_DispatcherPaths.createOrder}';
  static const String parseText = ModuleRoutePaths.dispatcherParseText;

  static const String chats = '$rootPath/${_DispatcherPaths.chats}';
  static String chatDetails(String id) => '$chats/$id';

  static const String riders = '$rootPath/${_DispatcherPaths.riders}';
  static const String ridersList = '$riders/${_DispatcherPaths.list}';
  static const String ridersMap = '$riders/${_DispatcherPaths.map}';
  static String riderDetails(String id) => '$riders/$id';

  static const String more = '$rootPath/${_DispatcherPaths.more}';
  static const String account = '$more/account';
  static const String requestIntegration = '$more/request';
}

/// Dispatcher module route configuration using StatefulShellRoute
List<RouteBase> get dispatcherRoutes => [
  StatefulShellRoute.indexedStack(
    redirect: (context, state) => const RedirectGuard(
      DispatcherRoutes.orders,
      from: DispatcherRoutes.rootPath,
    ).redirect(context, state.fullPath),
    builder: (_, _, navigationShell) {
      return DispatcherPage(navigationShell: navigationShell);
    },
    branches: [
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: DispatcherRoutes.chats,
            builder: (context, state) => const ChatsTab(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return ChatDetailPage(conversationId: id);
                },
              ),
            ],
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: DispatcherRoutes.orders,
            builder: (context, state) => const OrdersTab(),
            routes: [
              GoRoute(
                path: _DispatcherPaths.createOrder,
                builder: (context, state) => const CreateOrderPage(),
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
                          return ScaleTransition(
                            scale: animation.drive(
                              Tween<double>(
                                begin: 0.9,
                                end: 1,
                              ).chain(CurveTween(curve: Curves.easeOutQuart)),
                            ),
                            child: FadeTransition(
                              opacity: animation,
                              child: child,
                            ),
                          );
                        },
                        child: AIOrderParserDialog(initialValue: initialValue),
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
            path: DispatcherRoutes.riders,
            redirect: (context, state) => const RedirectGuard(
              DispatcherRoutes.ridersList,
              from: DispatcherRoutes.riders,
            ).redirect(context, state.fullPath),
            routes: [
              GoRoute(
                path: _DispatcherPaths.list,
                builder: (context, state) => const RidersListView(),
              ),
              GoRoute(
                path: _DispatcherPaths.map,
                builder: (context, state) {
                  return RidersMapView(riderId: state.extra as String?);
                },
              ),
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
            path: DispatcherRoutes.more,
            builder: (context, state) => const MoreTab(),
            routes: [
              GoRoute(
                path: 'account',
                builder: (context, state) {
                  final user = state.extra! as User;
                  return AccountPage(user: user);
                },
              ),
              GoRoute(
                path: 'request',
                pageBuilder: (context, state) {
                  return CustomTransitionPage(
                    key: state.pageKey,
                    opaque: false,
                    barrierDismissible: true,
                    barrierColor: Colors.black54,
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
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
                    child: const RequestIntegrationPage(),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    ],
  ),
];
