import 'package:adapters/adapters.dart';
import 'package:bootstrap/interfaces/connectivity/connectivity.dart';
import 'package:bootstrap/interfaces/http/token_store.dart';
import 'package:bootstrap/interfaces/modules/module/module.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';
import 'package:logistix/startup/presentation/bloc/app_bloc.dart';
import 'package:logistix/startup/presentation/pages/entry_splash_page.dart';
import 'package:shared/shared.dart';

class AppModule extends Module<RouteBase> {
  const AppModule();

  @override
  void registerServices(DI injector) {
    // Foundation - App-level services

    final tokenStoreRefresh = TokenStoreFreshDioAdapterInterceptor(
      createTokenStore(),
      refreshUrl: EnvConfig.instance.refreshUrl,
    );

    injector
      ..registerSingleton<Logger>(const SentryLogger())
      ..registerSingleton<TokenStore>(SecureTokenStore())
      ..registerSingleton<UserStore>(
        UserStoreImpl(
          SharedPrefsObjectStore(UserDto.fromJson, UserDto.toJsonFunc),
        ),
      )
      ..registerSingleton<IConnectivityService>(
        ConnectivityAdapter(Connectivity()),
      )
      ..registerLazySingleton<Dio>(
        () => DioFactory.build(
          baseUrl: EnvConfig.instance.apiUrl,
          interceptors: [
            tokenStoreRefresh,
            InterceptorsWrapper(
              onRequest: (options, handler) {
                options.headers['x-client-key'] = EnvConfig.instance.clientKey;
                return handler.next(options);
              },
            ),
          ],
        ),
      )
      ..registerLazySingleton<AuthStatusRepository>(
        () => AuthStatusRepositoryImpl(injector.get<UserStore>()),
      )
      ..registerLazySingleton<GraphQLService>(
        () => GraphQLService(
          injector.get<TokenStore>(),
          userStore: injector.get<UserStore>(),
          authStatus: injector.get<AuthStatusRepository>(),
          onRefreshToken: GraphQLService.defaultRefreshToken,
          logger: const DevLogger(),
        ),
      )
      // SyncManager Lazy Singleton
      ..registerLazySingleton<SyncManager>(
        () => SyncManager(
          injector.get<GraphQLService>(),
          injector.get<IConnectivityService>(),
          logger: injector.get<Logger>(),
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
          pushNotificationService: injector.get<PushNotificationService>(),
          appRepository: injector.get<AppRepository>(),
          authStatusRepository: injector.get<AuthStatusRepository>(),
        ),
      )
      ..registerLazySingleton<AppRepository>(
        () => AppRepositoryImpl(
          AppRemoteDataSourceImpl(injector.get<GraphQLService>()),
          injector.get<TokenStore>(),
          injector.get<UserStore>(),
        ),
      )
      // Register AppBloc for global app state and initialization
      ..registerSingleton<AppBloc>(
        AppBloc(
          injector.get<AppRepository>(),
          ClearAppDataUseCase(
            injector.get<TokenStore>(),
            injector.get<UserStore>(),
            injector.get<GraphQLService>(),
            injector.get<LogistixDatabase>(),
          ),
          injector.get<AuthStatusRepository>(),
        ),
      )
      ..registerLazySingleton<PushNotificationService>(
        PushNotificationServiceImpl.new,
      )
      ..registerLazySingleton<InitializeNotificationsUseCase>(
        () => InitializeNotificationsUseCase(
          injector.get<PushNotificationService>(),
          injector.get<AppRepository>(),
        ),
      )
      ..registerLazySingleton<ShareIntentService>(
        () => ShareIntentService(userStore: injector.get<UserStore>()),
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
