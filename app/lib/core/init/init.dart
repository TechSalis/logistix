import 'package:adapters/adapters.dart';
import 'package:auth/auth.dart';
import 'package:bootstrap/interfaces/di/di.dart';
import 'package:bootstrap/interfaces/http/token_store.dart';
import 'package:bootstrap/interfaces/logger/logger.dart';
import 'package:bootstrap/interfaces/modules/modules.dart';
import 'package:dispatcher/dispatcher.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:logistix/core/module/app_module.dart';
import 'package:logistix/core/router/app_router.dart';
import 'package:logistix/firebase_options.dart';
import 'package:logistix/startup/data/datasources/startup_remote_datasource.dart';
import 'package:logistix/startup/data/repositories/startup_repository_impl.dart';
import 'package:logistix/startup/presentation/bloc/app_bloc.dart';
import 'package:onboarding/onboarding.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rider/rider.dart';
import 'package:shared/shared.dart';

class AppInitialization {
  static Future<void> init(DI injector) async {
    FlutterError.onError = PlatformDispatcher.instance.onError = null;
    // 1. Load env vars and initialize core services
    await Future.wait<void>([
      Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform),
      SentryLogger.initSentry(
        EnvConfig.sentryDsn,
        environment: EnvConfig.environment,
      ),
      initHiveForFlutter(),
      _initHydratedStorage(),
      Future.value(appLogger.init()),
    ]);

    _registerDependencies(injector);

    // 3. Initialize Network Service (requires DI for token store)
    await injector.get<GraphQLService>().init(
      EnvConfig.graphqlUrl,
      wsUrl: EnvConfig.wsUrl,
    );
  }

  static Future<void> _initHydratedStorage() async {
    HydratedBloc.storage = await HydratedStorage.build(
      storageDirectory: await getApplicationDocumentsDirectory(),
    );
  }

  static void _registerDependencies(DI injector) {
    // Foundation - App-level services
    injector
      ..registerSingleton<Logger>(const SentryLogger())
      // Shared infrastructure
      ..registerSingleton<TokenStore>(SecureTokenStore())
      ..registerSingleton<UserStore>(
        UserStoreImpl(
          SharedPrefsObjectStore(UserDto.fromJson, UserDto.toJsonFunc),
        ),
      )
      ..registerSingleton<GraphQLService>(
        GraphQLService(
          injector.get<TokenStore>(),
          onRefreshToken: GraphQLService.defaultRefreshToken,
          logger: const DevLogger(),
        ),
      )
      ..registerSingleton<AppEventStreamManager>(
        AppEventStreamManager(
          EventStreamRemoteDataSourceImpl(injector.get<GraphQLService>()),
        ),
      )
      ..registerLazySingleton<LogoutUseCase>(
        () => LogoutUseCase(
          ClearAppDataUseCase(
            injector.get<TokenStore>(),
            injector.get<UserStore>(),
            injector.get<GraphQLService>(),
          ),
        ),
      )
      // Register AppBloc for global app state and initialization
      ..registerSingleton<AppBloc>(
        AppBloc(
          StartupRepositoryImpl(
            StartupRemoteDataSourceImpl(injector.get<GraphQLService>()),
            injector.get<TokenStore>(),
          ),
        ),
      );

    // Initialize modules using ModuleFactory
    final moduleFactory = ModuleFactory(
      injector: injector,
      routerFactory: GoRouterFactory(injector: injector, initialLocation: '/'),
      modules: [
        const AppModule(),
        const AuthModule(),
        const OnboardingModule(),
        const DispatcherModule(),
        const RiderModule(),
      ],
    )..registerServices();

    // Router (requires ModuleFactory)
    injector.registerSingleton<AppRouter>(AppRouter(moduleFactory, injector));
  }
}
