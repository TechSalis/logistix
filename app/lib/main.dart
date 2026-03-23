import 'package:adapters/adapters.dart';
import 'package:bootstrap/interfaces/di/di.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:logistix/core/init/init.dart';
import 'package:logistix/startup/presentation/bloc/app_bloc.dart';
import 'package:logistix/startup/presentation/bloc/app_state.dart';
import 'package:logistix_ux/logistix_ux.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared/shared.dart';

void main() async {
  SentryWidgetsFlutterBinding.ensureInitialized();

  DI.adapter = GetItDI.new;
  final injector = DI();

  runApp(
    DefaultAssetBundle(
      bundle: SentryAssetBundle(),
      child: LogistixApp(
        appRouter: await AppInitialization.init(injector),
        appBloc: injector.get<AppBloc>(),
      ),
    ),
  );
}

class LogistixApp extends StatelessWidget {
  const LogistixApp({
    required this.appRouter,
    required this.appBloc,
    super.key,
  });

  final AppBloc appBloc;
  final GoRouter appRouter;

  @override
  Widget build(BuildContext context) {
    void redirect(AppState state) {
      state.whenOrNull(
        unauthenticated: () => appRouter.go(ModuleRoutePaths.auth),
        needsOnboarding: (_) => appRouter.go(ModuleRoutePaths.onboarding),
        authenticated: (_, role) {
          switch (role) {
            case UserRole.rider:
              appRouter.go(ModuleRoutePaths.rider);
            case UserRole.dispatcher:
              appRouter.go(ModuleRoutePaths.dispatcher);
          }
        },
      );
    }

    // Trigger initial redirect if state is already ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!appBloc.state.isInitializing) redirect(appBloc.state);
    });

    return BlocProvider.value(
      value: appBloc,
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
