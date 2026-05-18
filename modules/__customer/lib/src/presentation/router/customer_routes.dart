import 'package:customer/src/domain/entities/customer_delivery_type.dart';
import 'package:customer/src/features/dashboard/presentation/view/customer_dashboard_page.dart';
import 'package:customer/src/features/dashboard/presentation/view/delivery_history_page.dart';
import 'package:customer/src/features/ordering/presentation/view/customer_delivery_form_page.dart';
import 'package:customer/src/features/ordering/presentation/view/delivery_details_page.dart';
import 'package:go_router/go_router.dart';
import 'package:shared/shared.dart';

abstract class _CustomerPaths {
  static const String delivery = 'delivery';
  static const String history = 'history';
  static const String companySelection = 'select-company';
}

abstract class CustomerRoutes {
  static const String rootPath = ModuleRoutePaths.customer;
  static const String makeDelivery = '$rootPath/${_CustomerPaths.delivery}';
  static const String history = '$rootPath/${_CustomerPaths.history}';
  static String deliveryDetails(String id) => '$history/$id';
  static const String companySelection =
      '$rootPath/${_CustomerPaths.companySelection}';
}

final customerRoutes = <RouteBase>[
  GoRoute(
    path: CustomerRoutes.rootPath,
    builder: (context, state) => const CustomerDashboardPage(),
    routes: [
      GoRoute(
        path: _CustomerPaths.delivery,
        builder: (context, state) => CustomerDeliveryFormPage(
          deliveryType: (state.extra as CustomerDeliveryType?) ??
              CustomerDeliveryType.generalErrands,
        ),
      ),
      GoRoute(
        path: _CustomerPaths.history,
        builder: (context, state) => const DeliveryHistoryPage(),
        routes: [
          GoRoute(
            path: ':id',
            builder: (context, state) => DeliveryDetailsPage(
              deliveryId: state.pathParameters['id']!,
            ),
          ),
        ],
      ),
    ],
  ),
];
