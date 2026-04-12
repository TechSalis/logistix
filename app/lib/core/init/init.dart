import 'package:adapters/adapters.dart';
import 'package:auth/auth.dart';
import 'package:bootstrap/interfaces/modules/modules.dart';
import 'package:dispatcher/dispatcher.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:logistix/core/module/app_module.dart';
import 'package:logistix/firebase_options.dart';
import 'package:onboarding/onboarding.dart';
import 'package:rider/rider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared/shared.dart';

class AppInitialization {
  static Future<GoRouter> init(DI injector) async {
    // 1. Load env vars and initialize core services
    await Future.wait<void>([
      Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform),
      _initLogger(),
      initHiveForFlutter(),
    ]);

    final router = _prepareRouter(injector);

    await Future.wait<void>([
      // 3. Initialize Network Service
      injector.get<GraphQLService>().init(
        EnvConfig.instance.graphqlUrl,
        wsUrl: EnvConfig.instance.wsUrl,
      ),
      // 4. Start listening for share intents
      injector.get<ShareIntentService>().init(router),
      // 5. Initialize Push Notifications
      injector.get<PushNotificationService>().init(),
    ]);

    return router;
  }

  static Future<void> _initLogger() async {
    Map<String, String>? redact(Map<String, String>? headers) {
      if (headers == null) return null;
      final h = Map.of(headers);
      for (final k in h.keys) {
        final key = k.toLowerCase();
        if (key.contains('authorization') || key.contains('token')) {
          h[k] = 'REDACTED';
        }
      }
      return h;
    }

    await SentryFlutter.init((o) {
      o
        ..dsn = EnvConfig.instance.sentryDsn
        ..environment = EnvConfig.instance.environment
        ..tracesSampleRate = 0.2
        ..attachScreenshot = true
        ..enableAppHangTracking = true
        ..enableAutoPerformanceTracing = true
        ..beforeSend = (event, hint) {
          return event
            ..request?.headers = redact(event.request?.headers) ?? {}
            ..request?.cookies = null;
        };
    });

    await appLogger.init();
  }

  static GoRouter _prepareRouter(DI injector) {
    // Initialize modules using ModuleFactory
    final moduleFactory = ModuleFactory(
      injector: injector,
      routerFactory: GoRouterFactory(
        injector: injector,
        initialLocation: '/',
        observers: [SentryNavigatorObserver()],
      ),
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
