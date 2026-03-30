import 'package:adapters/adapters.dart';
import 'package:bootstrap/interfaces/di/di.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:go_router/go_router.dart';
import 'package:logistix/core/init/init.dart';
import 'package:logistix/startup/presentation/bloc/app_bloc.dart';
import 'package:logistix/startup/presentation/bloc/app_event.dart';
import 'package:logistix/startup/presentation/bloc/app_state.dart';
import 'package:logistix_ux/logistix_ux.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared/shared.dart';

void main() async {
  FlutterNativeSplash.preserve(
    widgetsBinding: SentryWidgetsFlutterBinding.ensureInitialized(),
  );

  DI.adapter = GetItDI.new;
  final injector = DI();
  final appRouter = await AppInitialization.init(injector);

  runApp(
    DefaultAssetBundle(
      bundle: SentryAssetBundle(),
      child: LogistixApp(
        appRouter: appRouter,
        getAppBloc: injector.get<AppBloc>
      ),
    ),
  );
  
  FlutterNativeSplash.remove();
}

class LogistixApp extends StatelessWidget {
  const LogistixApp({
    required this.appRouter,
    required this.getAppBloc,
    super.key,
  });

  final ValueGetter<AppBloc> getAppBloc;
  final GoRouter appRouter;

  @override
  Widget build(BuildContext context) {
    void redirect(AppState state) {
      state.whenOrNull(
        unauthenticated: () => appRouter.go(ModuleRoutePaths.auth),
        needsOnboarding: (_) => appRouter.go(ModuleRoutePaths.onboarding),
        authenticated: (_, role) {
          appRouter.go(switch (role) {
            UserRole.rider => ModuleRoutePaths.rider,
            UserRole.dispatcher => ModuleRoutePaths.dispatcher,
            // UserRole.customer => ModuleRoutePaths.auth,
          });
        },
      );
    }

    return BlocProvider(
      create: (_) => getAppBloc()..add(const AppEvent.initialize()),
      child: BlocListener<AppBloc, AppState>(
        listener: (context, state) => redirect(state),
        child: MaterialApp.router(
          title: 'Logistix',
          theme: LogistixTheme.lightTheme,
          routerConfig: appRouter,
        ),
      ),
    );
  }
}
