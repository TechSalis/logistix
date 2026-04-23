import 'package:auth/auth.dart';
import 'package:auth/src/presentation/router/auth_routes.dart';
import 'package:bootstrap/interfaces/http/token_store.dart';
import 'package:bootstrap/interfaces/modules/modules.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared/shared.dart';

class AuthModule extends Module<RouteBase> {
  const AuthModule();

  @override
  void registerServices(DI injector) {
    injector.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(
        AuthRemoteDataSourceImpl(injector.get<GraphQLService>()),
        injector.get<TokenStore>(),
      ),
    );
  }

  @override
  Set<RouteBase> routes(DI injector) => {
    ShellRoute(
      builder: (context, state, child) {
        return BlocProvider<AuthBloc>(
          create: (context) {
            return AuthBloc(
              injector.get<AuthRepository>(),
              injector.get<UserStore>(),
              injector.get<AuthStatusRepository>(),
            );
          },
          child: ToastServiceWidget(child: child),
        );
      },
      routes: [
        GoRoute(
          path: AuthRoutes.rootPath,
          redirect: (context, state) => const RedirectGuard(
            AuthRoutes.login,
            from: AuthRoutes.rootPath,
          ).redirect(context, state.fullPath),
          routes: authRoutes,
        ),
      ],
    ),
  };
}
