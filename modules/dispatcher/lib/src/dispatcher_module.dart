import 'package:bootstrap/core.dart';
import 'package:bootstrap/interfaces/modules/modules.dart';
import 'package:bootstrap/interfaces/store/store.dart';
import 'package:dispatcher/src/core/network/sync/dispatcher_subscription_handler.dart';
import 'package:dispatcher/src/data/datasources/analytics_remote_datasource.dart';
import 'package:dispatcher/src/data/datasources/contact_remote_datasource.dart';
import 'package:dispatcher/src/data/datasources/dispatcher_session_remote_datasource.dart';
import 'package:dispatcher/src/data/datasources/order_remote_datasource.dart';
import 'package:dispatcher/src/data/datasources/rider_remote_datasource.dart';
import 'package:dispatcher/src/data/repositories/analytics_repository_impl.dart';
import 'package:dispatcher/src/data/repositories/contact_repository_impl.dart';
import 'package:dispatcher/src/data/repositories/metrics_repository_impl.dart';
import 'package:dispatcher/src/data/repositories/order_repository_impl.dart';
import 'package:dispatcher/src/data/repositories/rider_repository_impl.dart';
import 'package:dispatcher/src/domain/repositories/analytics_repository.dart';
import 'package:dispatcher/src/domain/repositories/contact_repository.dart';
import 'package:dispatcher/src/domain/repositories/metrics_repository.dart';
import 'package:dispatcher/src/domain/repositories/order_repository.dart';
import 'package:dispatcher/src/domain/repositories/rider_repository.dart';
import 'package:dispatcher/src/domain/usecases/dispatcher_initial_sync_provider.dart';
import 'package:dispatcher/src/domain/usecases/export_analytics_usecase.dart';
import 'package:dispatcher/src/domain/usecases/manage_dispatcher_session_usecase.dart';
import 'package:dispatcher/src/domain/usecases/request_integration_usecase.dart';
import 'package:dispatcher/src/domain/usecases/search_riders_usecase.dart';
import 'package:dispatcher/src/domain/usecases/sync_dispatcher_data_usecase.dart';
import 'package:dispatcher/src/features/more/presentation/cubit/more_cubit.dart';
import 'package:dispatcher/src/features/orders/presentation/cubit/create_order_cubit.dart';
import 'package:dispatcher/src/features/orders/presentation/cubit/metrics_cubit.dart';
import 'package:dispatcher/src/features/orders/presentation/cubit/orders_cubit.dart';
import 'package:dispatcher/src/features/riders/presentation/cubit/riders_cubit.dart';
import 'package:dispatcher/src/presentation/router/dispatcher_routes.dart';
import 'package:dispatcher/src/presentation/widgets/dispatcher_session_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared/shared.dart';

class DispatcherModule extends Module<RouteBase> {
  const DispatcherModule();

  @override
  Set<RouteBase> routes(DI injector) => {
    ShellRoute(
      builder: (context, state, child) => MultiRepositoryProvider(
        providers: [
          RepositoryProvider<DispatcherSessionRemoteDataSource>(
            create: (context) => DispatcherSessionRemoteDataSourceImpl(
              injector.get<GraphQLService>(),
            ),
          ),
          RepositoryProvider<DispatcherSubscriptionHandler>(
            create: (context) => DispatcherSubscriptionHandler(
              orderDao: injector.get<OrderDao>(),
              riderDao: injector.get<RiderDao>(),
              database: injector.get<LogistixDatabase>(),
              logger: injector.get<Logger>(),
            ),
          ),
          RepositoryProvider<OrderRepository>(
            create: (context) => OrderRepositoryImpl(
              remoteDataSource: OrderRemoteDataSourceImpl(
                injector.get<GraphQLService>(),
              ),
              orderDao: injector.get<OrderDao>(),
              riderDao: injector.get<RiderDao>(),
              placesService: injector.get<PlacesService>(),
            ),
          ),
          RepositoryProvider<RiderRepository>(
            create: (context) => RiderRepositoryImpl(
              RiderRemoteDataSourceImpl(injector.get<GraphQLService>()),
              injector.get<RiderDao>(),
            ),
          ),
          RepositoryProvider<MetricsRepository>(
            create: (context) => MetricsRepositoryImpl(
              injector.get<LogistixDatabase>(),
              injector.get<UserStore>(),
            ),
          ),
          RepositoryProvider<AnalyticsRepository>(
            create: (context) => AnalyticsRepositoryImpl(
              AnalyticsRemoteDataSourceImpl(injector.get<RestService>()),
            ),
          ),
          RepositoryProvider<ContactRepository>(
            create: (context) => ContactRepositoryImpl(
              ContactRemoteDataSourceImpl(injector.get<GraphQLService>()),
            ),
          ),
          RepositoryProvider<SearchRidersUseCase>(
            create: (context) {
              return SearchRidersUseCase(context.read<RiderRepository>());
            },
          ),
          RepositoryProvider<SyncDispatcherDataUseCase>(
            create: (context) => SyncDispatcherDataUseCase(
              remoteDataSource:
                  context.read<DispatcherSessionRemoteDataSource>(),
              orderDao: injector.get<OrderDao>(),
              riderDao: injector.get<RiderDao>(),
              metricsStore:
                  injector.get<StreamableObjectStore<DispatcherMetricsDto>>(),
              database: injector.get<LogistixDatabase>(),
            ),
          ),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => CreateOrderCubit(
                context.read<OrderRepository>(),
                context.read<SearchRidersUseCase>(),
              ),
            ),
            BlocProvider<OrdersCubit>(
              create: (context) => OrdersCubit(context.read<OrderRepository>()),
            ),
            BlocProvider<RidersCubit>(
              create: (context) => RidersCubit(context.read<RiderRepository>()),
            ),
            BlocProvider<AddressCubit>(
              create: (context) => AddressCubit(injector.get<PlacesService>()),
            ),
            BlocProvider<MetricsCubit>(
              create: (context) {
                return MetricsCubit(context.read<MetricsRepository>());
              },
            ),
            BlocProvider<MapCubit>(create: (context) => MapCubit()),
            BlocProvider<MoreCubit>(
              create: (context) => MoreCubit(
                injector.get<AuthStatusRepository>(),
                injector.get<UserStore>(),
                ExportAnalyticsUseCase(context.read<AnalyticsRepository>()),
                RequestIntegrationUseCase(context.read<ContactRepository>()),
              ),
            ),
          ],
          child: Builder(
            builder: (context) {
              return DispatcherSessionProvider(
                sessionManager: DispatcherSessionManager(
                  context.read<DispatcherSessionRemoteDataSource>(),
                  context.read<DispatcherSubscriptionHandler>(),
                  injector.get<LogistixDatabase>(),
                  context.read<SyncDispatcherDataUseCase>(),
                ),
                child: ToastServiceWidget(child: child),
              );
            },
          ),
        ),
      ),
      routes: [
        GoRoute(
          path: DispatcherRoutes.rootPath,
          pageBuilder: (context, state) => SyncPage.page(
            state: state,
            onInitialize: () => DispatcherInitialSyncProvider(
              database: injector.get<LogistixDatabase>(),
              syncDispatcherDataUseCase: context
                  .read<SyncDispatcherDataUseCase>(),
            ).performInitialSync(),
            onSuccess: () => context.go(DispatcherRoutes.orders),
            onError: (context, e, retry) {
              SyncPage.showErrorDialog(
                context,
                error: e,
                onRetry: retry,
                onLogout: injector
                    .get<AuthStatusRepository>()
                    .setUnauthenticated,
              );
            },
          ),
        ),
        ...dispatcherRoutes,
      ],
    ),
  };
}
