import 'package:bootstrap/core.dart';
import 'package:bootstrap/interfaces/modules/modules.dart';
import 'package:customer/src/core/network/sync/customer_subscription_handler.dart';
import 'package:customer/src/data/datasources/order_remote_datasource.dart';
import 'package:customer/src/data/repositories/order_repository_impl.dart';
import 'package:customer/src/domain/repositories/customer_order_repository.dart';
import 'package:customer/src/domain/usecases/manage_customer_session_usecase.dart';
import 'package:customer/src/domain/usecases/sync_customer_data_usecase.dart';
import 'package:customer/src/features/dashboard/presentation/cubit/order_history_cubit.dart';
import 'package:customer/src/features/ordering/presentation/cubit/customer_address_cubit.dart';
import 'package:customer/src/features/ordering/presentation/cubit/order_form_cubit.dart';
import 'package:customer/src/presentation/router/customer_routes.dart';
import 'package:customer/src/presentation/widgets/customer_session_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared/shared.dart';

class CustomerModule extends Module<RouteBase> {
  const CustomerModule();

  @override
  Set<RouteBase> routes(DI injector) => {
        ShellRoute(
          builder: (context, state, child) => MultiRepositoryProvider(
            providers: [
              RepositoryProvider<CustomerOrderRemoteDataSource>(
                create: (_) => CustomerOrderRemoteDataSourceImpl(
                  injector.get<GraphQLService>(),
                ),
              ),
              RepositoryProvider<CustomerOrderRepository>(
                create: (context) => CustomerOrderRepositoryImpl(
                  remoteDataSource:
                      context.read<CustomerOrderRemoteDataSource>(),
                  orderDao: injector.get<OrderDao>(),
                  userStore: injector.get<UserStore>(),
                ),
              ),
              RepositoryProvider<CustomerSubscriptionHandler>(
                create: (context) => CustomerSubscriptionHandler(
                  orderDao: injector.get<OrderDao>(),
                  riderDao: injector.get<RiderDao>(),
                  logger: injector.get<Logger>(),
                ),
              ),
              RepositoryProvider<SyncCustomerDataUseCase>(
                create: (context) => SyncCustomerDataUseCase(
                  remoteDataSource: context.read<CustomerOrderRemoteDataSource>(),
                  orderDao: injector.get<OrderDao>(),
                  database: injector.get<LogistixDatabase>(),
                ),
              ),
            ],
            child: MultiBlocProvider(
              providers: [
                BlocProvider<OrderHistoryCubit>(
                  create: (context) => OrderHistoryCubit(
                    context.read<CustomerOrderRepository>(),
                  ),
                ),
                BlocProvider<OrderFormCubit>(
                  create: (context) => OrderFormCubit(
                    context.read<CustomerOrderRepository>(),
                  ),
                ),
                BlocProvider<CustomerAddressCubit>(
                  create: (_) {
                    return CustomerAddressCubit(injector.get<PlacesService>());
                  },
                ),
              ],
              child: Builder(
                builder: (context) {
                  return CustomerSessionProvider(
                    sessionManager: CustomerSessionManager(
                      context.read<CustomerOrderRemoteDataSource>(),
                      context.read<CustomerSubscriptionHandler>(),
                      injector.get<LogistixDatabase>(),
                      context.read<SyncCustomerDataUseCase>(),
                    ),
                    child: ToastServiceWidget(child: child),
                  );
                },
              ),
            ),
          ),
          routes: customerRoutes,
        ),
      };
}
