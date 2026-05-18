import 'package:bootstrap/interfaces/modules/modules.dart';
import 'package:customer/src/core/network/sync/customer_subscription_handler.dart';
import 'package:customer/src/data/datasources/delivery_remote_datasource.dart';
import 'package:customer/src/data/repositories/delivery_repository_impl.dart';
import 'package:customer/src/domain/repositories/customer_delivery_repository.dart';
import 'package:customer/src/domain/usecases/manage_customer_session_usecase.dart';
import 'package:customer/src/domain/usecases/sync_customer_data_usecase.dart';
import 'package:customer/src/features/dashboard/presentation/cubit/delivery_history_cubit.dart';
import 'package:customer/src/features/ordering/presentation/cubit/customer_address_cubit.dart';
import 'package:customer/src/features/ordering/presentation/cubit/delivery_form_cubit.dart';
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
              RepositoryProvider<CustomerDeliveryRemoteDataSource>(
                create: (_) => CustomerDeliveryRemoteDataSourceImpl(
                  injector.get<GraphQLService>(),
                  injector.get<SyncManager>(),
                ),
              ),
              RepositoryProvider<CustomerDeliveryRepository>(
                create: (context) => CustomerDeliveryRepositoryImpl(
                  remoteDataSource:
                      context.read<CustomerDeliveryRemoteDataSource>(),
                  deliveryDao: injector.get<DeliveryDao>(),
                  userStore: injector.get<UserStore>(),
                ),
              ),
              RepositoryProvider<CustomerSubscriptionHandler>(
                create: (context) => CustomerSubscriptionHandler(
                  deliveryDao: injector.get<DeliveryDao>(),
                  riderDao: injector.get<RiderDao>(),
                  logger: injector.get<Logger>(),
                ),
              ),
              RepositoryProvider<SyncCustomerDataUseCase>(
                create: (context) => SyncCustomerDataUseCase(
                  remoteDataSource: context.read<CustomerDeliveryRemoteDataSource>(),
                  deliveryDao: injector.get<DeliveryDao>(),
                  database: injector.get<LogistixDatabase>(),
                ),
              ),
            ],
            child: MultiBlocProvider(
              providers: [
                BlocProvider<DeliveryHistoryCubit>(
                  create: (context) => DeliveryHistoryCubit(
                    context.read<CustomerDeliveryRepository>(),
                  ),
                ),
                BlocProvider<DeliveryFormCubit>(
                  create: (context) => DeliveryFormCubit(
                    context.read<CustomerDeliveryRepository>(),
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
                      context.read<CustomerDeliveryRemoteDataSource>(),
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
