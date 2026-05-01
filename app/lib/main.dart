import 'package:adapters/adapters.dart';
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

  EnvConfig.instance = EnvConfig();
  DI.adapter = GetItDI.new;
  final injector = DI();
  final appRouter = await AppInitialization.init(injector);

  runApp(
    DefaultAssetBundle(
      bundle: SentryAssetBundle(),
      child: LogistixApp(
        appRouter: appRouter,
        getAppBloc: injector.get<AppBloc>,
        graphQLService: injector.get<GraphQLService>(),
      ),
    ),
  );

  FlutterNativeSplash.remove();
}

class LogistixApp extends StatefulWidget {
  const LogistixApp({
    required this.appRouter,
    required this.getAppBloc,
    required this.graphQLService,
    super.key,
  });

  final ValueGetter<AppBloc> getAppBloc;
  final GoRouter appRouter;
  final GraphQLService graphQLService;

  @override
  State<LogistixApp> createState() => _LogistixAppState();
}

class _LogistixAppState extends State<LogistixApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.graphQLService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    void redirect(AppState state) {
      state.whenOrNull(
        unauthenticated: () => widget.appRouter.go(ModuleRoutePaths.auth),
        needsOnboarding: (_) => widget.appRouter.go(ModuleRoutePaths.onboarding),
        authenticated: (_, role) {
          widget.appRouter.go(switch (role) {
            UserRole.RIDER => ModuleRoutePaths.rider,
            UserRole.DISPATCHER => ModuleRoutePaths.dispatcher,
            UserRole.CUSTOMER => ModuleRoutePaths.auth,
          });
        },
      );
    }

    return BlocProvider(
      create: (_) => widget.getAppBloc()..add(const AppEvent.initialize()),
      child: BlocListener<AppBloc, AppState>(
        listener: (context, state) => redirect(state),
        child: MaterialApp.router(
          title: ProjectConfig.brandName,
          theme: LogistixTheme.lightTheme,
          routerConfig: widget.appRouter,
        ),
      ),
    );
  }
}
