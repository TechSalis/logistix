import 'package:adapters/adapters.dart';
import 'package:bootstrap/interfaces/modules/modules.dart';
import 'package:bootstrap/interfaces/store/store.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:rider/src/core/network/sync/rider_subscription_handler.dart';
import 'package:rider/src/data/datasources/rider_remote_datasource.dart';
import 'package:rider/src/data/repositories/rider_repository_impl.dart';
import 'package:rider/src/domain/repositories/rider_repository.dart';
import 'package:rider/src/domain/usecases/manage_rider_session_usecase.dart';
import 'package:rider/src/domain/usecases/rider_initial_sync_provider.dart';
import 'package:rider/src/domain/usecases/sync_rider_data_usecase.dart';
import 'package:rider/src/features/map/presentation/cubit/rider_map_orders_cubit.dart';
import 'package:rider/src/features/orders/data/dtos/rider_metrics_dto.dart';
import 'package:rider/src/features/orders/presentation/cubit/rider_metrics_cubit.dart';
import 'package:rider/src/features/orders/presentation/cubit/rider_orders_cubit.dart';
import 'package:rider/src/presentation/bloc/rider_bloc.dart';
import 'package:rider/src/presentation/router/rider_routes.dart';
import 'package:shared/shared.dart';

class RiderModule extends Module<RouteBase> {
  const RiderModule();

  @override
  void registerServices(DI injector) {
    injector.registerSingleton<StreamableObjectStore<RiderMetricsDto>>(
      StreamableSharedPrefsObjectStore(
        RiderMetricsDto.fromJson,
        RiderMetricsDto.toJsonFunc,
      ),
    );
  }

  @override
  Set<RouteBase> routes(DI injector) => {
    ShellRoute(
      builder: (context, state, child) => MultiRepositoryProvider(
        providers: [
          RepositoryProvider<RiderRemoteDataSource>(
            create: (context) {
              return RiderRemoteDataSourceImpl(
                injector.get<GraphQLService>(),
                injector.get<SyncManager>(),
              );
            },
          ),
          RepositoryProvider<RiderSubscriptionHandler>(
            create: (context) => RiderSubscriptionHandler(
              orderDao: injector.get<OrderDao>(),
              riderDao: injector.get<RiderDao>(),
              metricsStore: injector
                  .get<StreamableObjectStore<RiderMetricsDto>>(),
              logger: injector.get<Logger>(),
            ),
          ),
          RepositoryProvider<RiderRepository>(
            create: (context) => RiderRepositoryImpl(
              remoteDataSource: context.read<RiderRemoteDataSource>(),
              orderDao: injector.get<OrderDao>(),
              riderDao: injector.get<RiderDao>(),
              metricsStore: injector
                  .get<StreamableObjectStore<RiderMetricsDto>>(),
            ),
          ),
          RepositoryProvider<SyncRiderDataUseCase>(
            create: (context) => SyncRiderDataUseCase(
              remoteDataSource: context.read<RiderRemoteDataSource>(),
              orderDao: injector.get<OrderDao>(),
              riderDao: injector.get<RiderDao>(),
              metricsStore:
                  injector.get<StreamableObjectStore<RiderMetricsDto>>(),
              database: injector.get<LogistixDatabase>(),
            ),
          ),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider<RiderBloc>(
              create: (context) => RiderBloc(
                context.read<RiderRepository>(),
                injector.get<LogoutUseCase>(),
                injector.get<DeactivateAccountUseCase>(),
                injector.get<UserStore>(),
              ),
            ),
            BlocProvider<RiderOrdersCubit>(
              create: (context) =>
                  RiderOrdersCubit(context.read<RiderRepository>()),
            ),
            BlocProvider<RiderMetricsCubit>(
              create: (context) =>
                  RiderMetricsCubit(context.read<RiderRepository>()),
            ),
            BlocProvider<MapCubit>(create: (context) => MapCubit()),
            BlocProvider<RiderMapOrdersCubit>(
              create: (context) =>
                  RiderMapOrdersCubit(context.read<RiderRepository>()),
            ),
          ],
          child: RepositoryProvider<RiderSessionManager>(
            create: (context) => RiderSessionManager(
              dataSource: context.read<RiderRemoteDataSource>(),
              subscriptionHandler: context.read<RiderSubscriptionHandler>(),
              riderDao: injector.get<RiderDao>(),
              database: injector.get<LogistixDatabase>(),
              syncUseCase: context.read<SyncRiderDataUseCase>(),
              riderBloc: context.read<RiderBloc>(),
            ),
            child: ToastServiceWidget(child: child),
          ),
        ),
      ),
      routes: [
        GoRoute(
          path: RiderRoutes.rootPath,
          pageBuilder: (context, state) => SyncPage.page(
            state: state,
            onInitialize: () => RiderInitialSyncProvider(
              riderDao: injector.get<RiderDao>(),
              userStore: injector.get<UserStore>(),
              database: injector.get<LogistixDatabase>(),
              syncRiderDataUseCase: context.read<SyncRiderDataUseCase>(),
            ).performInitialSync(),
            onSuccess: () => context.go(RiderRoutes.map),
            onError: (context, error, retry) {
              SyncPage.showErrorDialog(
                context,
                error: error,
                onRetry: retry,
                onLogout: () => injector.get<LogoutUseCase>().call(),
              );
            },
          ),
        ),
        ...riderRoutes,
      ],
    ),
  };
}
