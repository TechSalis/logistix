import 'package:bootstrap/interfaces/di/di.dart';
import 'package:bootstrap/interfaces/modules/module/module.dart';
import 'package:go_router/go_router.dart';
import 'package:logistix/startup/presentation/bloc/app_bloc.dart';
import 'package:logistix/startup/presentation/pages/splash_page.dart';

class AppModule extends Module<RouteBase> {
  const AppModule();

  @override
  Set<RouteBase> routes(DI injector) {
    return {
      GoRoute(
        path: '/',
        builder: (context, state) {
          return SplashPage(appBloc: injector.get<AppBloc>());
        },
      ),
    };
  }
}
