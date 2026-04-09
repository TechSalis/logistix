import '../../domain/entities/customer_order_type.dart';
import '../../features/dashboard/presentation/view/customer_dashboard_page.dart';
import '../../features/dashboard/presentation/view/order_history_page.dart';
import '../../features/ordering/presentation/view/customer_order_form_page.dart';
import '../../features/ordering/presentation/view/order_details_page.dart';
import 'package:go_router/go_router.dart';
import 'package:shared/shared.dart';

abstract class _CustomerPaths {
  static const String order = 'order';
  static const String history = 'history';
  static const String companySelection = 'select-company';
}

abstract class CustomerRoutes {
  static const String rootPath = ModuleRoutePaths.customer;
  static const String makeOrder = '$rootPath/${_CustomerPaths.order}';
  static const String history = '$rootPath/${_CustomerPaths.history}';
  static String orderDetails(String id) => '$history/$id';
  static const String companySelection =
      '$rootPath/${_CustomerPaths.companySelection}';
}

final customerRoutes = <RouteBase>[
  GoRoute(
    path: CustomerRoutes.rootPath,
    builder: (context, state) => const CustomerDashboardPage(),
    routes: [
      GoRoute(
        path: _CustomerPaths.order,
        builder: (context, state) => CustomerOrderFormPage(
          orderType: (state.extra as CustomerOrderType?) ??
              CustomerOrderType.generalErrands,
        ),
      ),
      GoRoute(
        path: _CustomerPaths.history,
        builder: (context, state) => const OrderHistoryPage(),
        routes: [
          GoRoute(
            path: ':id',
            builder: (context, state) => OrderDetailsPage(
              orderId: state.pathParameters['id']!,
            ),
          ),
        ],
      ),
    ],
  ),
];
