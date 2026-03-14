import 'dart:async';

import 'package:bootstrap/core.dart';
import 'package:bootstrap/interfaces/modules/modules.dart';
import 'package:go_router/go_router.dart';
import 'package:logistix/startup/presentation/bloc/app_bloc.dart';
import 'package:logistix/startup/presentation/bloc/app_state.dart';
import 'package:shared/shared.dart';



class AppRouter {
  AppRouter(this.moduleFactory, this.injector);

  final DI injector;
  final ModuleFactory<RouteBase, GoRouter> moduleFactory;

  StreamSubscription<AppState>? _appBlocSubscription;

  late final router = moduleFactory.routerConfig;

  void startListening() {
    final appBloc = injector.get<AppBloc>();

    _appBlocSubscription = appBloc.stream.listen((state) {
      state.when(
        initializing: () {
          // Stay on splash screen
          if (router.routerDelegate.currentConfiguration.uri.path != '/') {
            router.go('/');
          }
        },
        unauthenticated: () => router.go(ModuleRoutePaths.auth),
        needsOnboarding: (_) => router.go(ModuleRoutePaths.onboarding),
        authenticated: (user, role) {
          switch (role) {
            case UserRole.rider:
              router.go(ModuleRoutePaths.rider);
            case UserRole.dispatcher:
              router.go(ModuleRoutePaths.dispatcher);
          }
        },
      );
    });
  }

  void dispose() => _appBlocSubscription?.cancel();
}
