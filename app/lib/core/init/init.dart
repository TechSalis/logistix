import 'package:adapters/adapters.dart';
import 'package:auth/auth.dart';
import 'package:bootstrap/interfaces/di/di.dart';
import 'package:bootstrap/interfaces/modules/modules.dart';
import 'package:dispatcher/dispatcher.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:logistix/core/module/app_module.dart';
import 'package:logistix/core/services/share_intent_service.dart';
import 'package:logistix/firebase_options.dart';
import 'package:onboarding/onboarding.dart';
import 'package:rider/rider.dart';
import 'package:shared/shared.dart';

class AppInitialization {
  static Future<GoRouter> init(DI injector) async {
    // 1. Load env vars and initialize core services
    await Future.wait<void>([
      Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform),
      SentryLogger.initSentry(
        EnvConfig.sentryDsn,
        environment: EnvConfig.environment,
      ),
      initHiveForFlutter(),
      Future.value(appLogger.init()),
    ]);

    final router = _prepareRouter(injector);

    await Future.wait([
      // 3. Initialize Network Service
      injector.get<GraphQLService>().init(
        EnvConfig.graphqlUrl,
        wsUrl: EnvConfig.wsUrl,
      ),
      // 4. Start listening for share intents
      injector.get<ShareIntentService>().init(router),
    ]);

    return router;
  }

  static GoRouter _prepareRouter(DI injector) {
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

    return moduleFactory.routerConfig;
  }
}
