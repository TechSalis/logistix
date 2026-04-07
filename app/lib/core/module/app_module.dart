import 'package:adapters/adapters.dart';
import 'package:bootstrap/interfaces/connectivity/connectivity.dart';
import 'package:bootstrap/interfaces/di/di.dart';
import 'package:bootstrap/interfaces/http/token_store.dart';
import 'package:bootstrap/interfaces/logger/logger.dart';
import 'package:bootstrap/interfaces/modules/module/module.dart';
import 'package:bootstrap/interfaces/store/store.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:go_router/go_router.dart';
import 'package:logistix/core/services/share_intent_service.dart';
import 'package:logistix/startup/data/datasources/startup_remote_datasource.dart';
import 'package:logistix/startup/data/repositories/startup_repository_impl.dart';
import 'package:logistix/startup/presentation/bloc/app_bloc.dart';
import 'package:logistix/startup/presentation/pages/entry_splash_page.dart';
import 'package:shared/shared.dart';

class AppModule extends Module<RouteBase> {
  const AppModule();

  @override
  void registerServices(DI injector) {
    // Foundation - App-level services
    injector
      ..registerSingleton<Logger>(const SentryLogger())
      ..registerSingleton<TokenStore>(SecureTokenStore())
      ..registerSingleton<UserStore>(
        UserStoreImpl(
          SharedPrefsObjectStore(UserDto.fromJson, UserDto.toJsonFunc),
        ),
      )
      ..registerSingleton<StreamableObjectStore<DispatcherMetricsDto>>(
        StreamableSharedPrefsObjectStore(
          DispatcherMetricsDto.fromJson,
          DispatcherMetricsDto.toJsonFunc,
        ),
      )
      ..registerSingleton<StreamableObjectStore<RiderMetricsDto>>(
        StreamableSharedPrefsObjectStore(
          RiderMetricsDto.fromJson,
          RiderMetricsDto.toJsonFunc,
        ),
      )
      ..registerSingleton<IConnectivityService>(
        ConnectivityAdapter(Connectivity()),
      )
      ..registerLazySingleton<AuthStatusRepository>(
        () => AuthStatusRepositoryImpl(injector.get<UserStore>()),
      )
      ..registerLazySingleton<GraphQLService>(
        () => GraphQLService(
          injector.get<TokenStore>(),
          userStore: injector.get<UserStore>(),
          connectivity: injector.get<IConnectivityService>(),
          authStatus: injector.get<AuthStatusRepository>(),
          onRefreshToken: GraphQLService.defaultRefreshToken,
          logger: const DevLogger(),
        ),
      )
      // Drift Database - Local storage
      ..registerSingleton<LogistixDatabase>(LogistixDatabase())
      ..registerLazySingleton<OrderDao>(
        () => OrderDao(injector.get<LogistixDatabase>()),
      )
      ..registerLazySingleton<RiderDao>(
        () => RiderDao(injector.get<LogistixDatabase>()),
      )

      ..registerLazySingleton<LogoutUseCase>(
        () => LogoutUseCase(
          ClearAppDataUseCase(
            injector.get<TokenStore>(),
            injector.get<UserStore>(),
            injector.get<GraphQLService>(),
            injector.get<LogistixDatabase>(),
          ),
        ),
      )
      // Register AppBloc for global app state and initialization
      ..registerSingleton<AppBloc>(
        AppBloc(
          StartupRepositoryImpl(
            StartupRemoteDataSourceImpl(injector.get<GraphQLService>()),
            injector.get<TokenStore>(),
            injector.get<UserStore>(),
          ),
          injector.get<LogoutUseCase>(),
          injector.get<AuthStatusRepository>(),
        ),
      )
      ..registerSingleton<ShareIntentService>(
        ShareIntentService(userStore: injector.get<UserStore>()),
      )
      ..registerLazySingleton<PlacesService>(PlacesService.new);
  }

  @override
  Set<RouteBase> routes(DI injector) {
    return {
      GoRoute(
        path: '/',
        pageBuilder: (context, state) => NoTransitionPage(
          key: state.pageKey,
          child: EntrySplashPage(
            appBloc: injector.get<AppBloc>(),
            onLogout: injector.get<LogoutUseCase>().call,
          ),
        ),
      ),
    };
  }
}
