import 'package:adapters/adapters.dart';
import 'package:bootstrap/interfaces/modules/modules.dart';
import 'package:bootstrap/interfaces/store/store.dart';
import 'package:dio/dio.dart';
import 'package:dispatcher/src/core/network/sync/dispatcher_subscription_handler.dart';
import 'package:dispatcher/src/data/datasources/dispatcher_session_remote_datasource.dart';
import 'package:dispatcher/src/data/datasources/rider_remote_datasource.dart';
import 'package:dispatcher/src/data/repositories/rider_repository_impl.dart';
import 'package:dispatcher/src/domain/repositories/rider_repository.dart';
import 'package:dispatcher/src/domain/usecases/dispatcher_initial_sync_provider.dart';
import 'package:dispatcher/src/domain/usecases/manage_dispatcher_session_usecase.dart';
import 'package:dispatcher/src/domain/usecases/search_riders_usecase.dart';
import 'package:dispatcher/src/domain/usecases/sync_dispatcher_data_usecase.dart';
import 'package:dispatcher/src/features/chat/data/datasources/chat_local_datasource.dart';
import 'package:dispatcher/src/features/chat/data/datasources/chat_remote_datasource.dart';
import 'package:dispatcher/src/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:dispatcher/src/features/chat/domain/repositories/chat_repository.dart';
import 'package:dispatcher/src/features/chat/domain/usecases/chat_session_manager.dart';
import 'package:dispatcher/src/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:dispatcher/src/features/more/data/datasources/analytics_remote_datasource.dart';
import 'package:dispatcher/src/features/more/data/datasources/contact_remote_datasource.dart';
import 'package:dispatcher/src/features/more/data/repositories/analytics_repository_impl.dart';
import 'package:dispatcher/src/features/more/data/repositories/contact_repository_impl.dart';
import 'package:dispatcher/src/features/more/domain/repositories/analytics_repository.dart';
import 'package:dispatcher/src/features/more/domain/repositories/contact_repository.dart';
import 'package:dispatcher/src/features/more/domain/usecases/export_analytics_usecase.dart';
import 'package:dispatcher/src/features/more/domain/usecases/get_integrations_usecase.dart';
import 'package:dispatcher/src/features/more/domain/usecases/request_integration_usecase.dart';
import 'package:dispatcher/src/features/more/presentation/cubit/more_cubit.dart';
import 'package:dispatcher/src/features/orders/data/datasources/order_remote_datasource.dart';
import 'package:dispatcher/src/features/orders/data/dtos/dispatcher_metrics_dto.dart';
import 'package:dispatcher/src/features/orders/data/repositories/metrics_repository_impl.dart';
import 'package:dispatcher/src/features/orders/data/repositories/order_repository_impl.dart';
import 'package:dispatcher/src/features/orders/domain/repositories/metrics_repository.dart';
import 'package:dispatcher/src/features/orders/domain/repositories/order_repository.dart';
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
  void registerServices(DI injector) {
    injector
      ..registerLazySingleton<ChatDao>(
        () => ChatDao(injector.get<LogistixDatabase>()),
      )
      ..registerSingleton<StreamableObjectStore<DispatcherMetricsDto>>(
        StreamableSharedPrefsObjectStore(
          DispatcherMetricsDto.fromJson,
          DispatcherMetricsDto.toJsonFunc,
        ),
      );
  }

  @override
  Set<RouteBase> routes(DI injector) => {
    ShellRoute(
      builder: (context, state, child) => MultiRepositoryProvider(
        providers: [
          RepositoryProvider<DispatcherSessionRemoteDataSource>(
            create: (context) => DispatcherSessionRemoteDataSourceImpl(
              injector.get<GraphQLService>(),
              injector.get<SyncManager>(),
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
          RepositoryProvider<DispatcherSubscriptionHandler>(
            create: (context) => DispatcherSubscriptionHandler(
              orderDao: injector.get<OrderDao>(),
              riderDao: injector.get<RiderDao>(),
              metricsStore: injector
                  .get<StreamableObjectStore<DispatcherMetricsDto>>(),
              logger: injector.get<Logger>(),
            ),
          ),
          RepositoryProvider<MetricsRepository>(
            create: (context) => MetricsRepositoryImpl(
              injector.get<StreamableObjectStore<DispatcherMetricsDto>>(),
            ),
          ),
          RepositoryProvider<AnalyticsRepository>(
            create: (context) => AnalyticsRepositoryImpl(
              AnalyticsRemoteDataSourceImpl(injector.get<Dio>()),
            ),
          ),
          RepositoryProvider<ContactRepository>(
            create: (context) => ContactRepositoryImpl(
              ContactRemoteDataSourceImpl(injector.get<GraphQLService>()),
            ),
          ),
          RepositoryProvider<ChatRemoteDataSource>(
            create: (context) => ChatRemoteDataSourceImpl(
              injector.get<GraphQLService>(),
              injector.get<SyncManager>(),
            ),
          ),
          RepositoryProvider<ChatLocalDataSource>(
            create: (context) {
              final user = injector.get<UserStore>().user;
              return ChatLocalDataSource(
                chatDao: injector.get<ChatDao>(),
                companyId: user?.companyId ?? '',
                userId: user?.id,
              );
            },
          ),
          RepositoryProvider<ChatSessionManager>(
            create: (context) => ChatSessionManager(
              context.read<ChatRemoteDataSource>(),
              context.read<ChatLocalDataSource>(),
            ),
          ),
          RepositoryProvider<ChatRepository>(
            create: (context) => ChatRepositoryImpl(
              remoteDataSource: context.read<ChatRemoteDataSource>(),
              localDataSource: context.read<ChatLocalDataSource>(),
              sessionManager: context.read<ChatSessionManager>(),
            ),
          ),
          RepositoryProvider<SearchRidersUseCase>(
            create: (context) {
              return SearchRidersUseCase(context.read<RiderRepository>());
            },
          ),
          RepositoryProvider<SyncDispatcherDataUseCase>(
            create: (context) => SyncDispatcherDataUseCase(
              remoteDataSource: context
                  .read<DispatcherSessionRemoteDataSource>(),
              orderDao: injector.get<OrderDao>(),
              riderDao: injector.get<RiderDao>(),
              chatDao: injector.get<ChatDao>(),
              metricsStore: injector
                  .get<StreamableObjectStore<DispatcherMetricsDto>>(),
              database: injector.get<LogistixDatabase>(),
              userStore: injector.get<UserStore>(),
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
            BlocProvider<ChatCubit>(
              create: (context) => ChatCubit(context.read<ChatRepository>()),
            ),
            BlocProvider<MapCubit>(create: (context) => MapCubit()),
            BlocProvider<MoreCubit>(
              create: (context) => MoreCubit(
                injector.get<UserStore>(),
                ExportAnalyticsUseCase(context.read<AnalyticsRepository>()),
                RequestIntegrationUseCase(context.read<ContactRepository>()),
                GetIntegrationsUseCase(context.read<ContactRepository>()),
                injector.get<LogoutUseCase>(),
              ),
            ),
          ],
          child: Builder(
            builder: (context) {
              return DispatcherSessionProvider(
                sessionManager: DispatcherSessionManager(
                  dataSource: context.read<DispatcherSessionRemoteDataSource>(),
                  subscriptionHandler: context
                      .read<DispatcherSubscriptionHandler>(),
                  database: injector.get<LogistixDatabase>(),
                  syncUseCase: context.read<SyncDispatcherDataUseCase>(),
                  initializeNotifications: injector
                      .get<InitializeNotificationsUseCase>(),
                  chatSessionManager: context.read<ChatSessionManager>(),
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
                onLogout: () => injector.get<LogoutUseCase>().call(),
              );
            },
          ),
        ),
        ...dispatcherRoutes,
      ],
    ),
  };
}
