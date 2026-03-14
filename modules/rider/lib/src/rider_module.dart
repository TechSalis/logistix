import 'package:bootstrap/core.dart';
import 'package:bootstrap/interfaces/di/di.dart';
import 'package:bootstrap/interfaces/modules/modules.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:rider/src/data/datasources/rider_remote_datasource.dart';
import 'package:rider/src/data/repositories/rider_repository_impl.dart';
import 'package:rider/src/domain/repositories/rider_repository.dart';
import 'package:rider/src/domain/usecases/manage_rider_session_usecase.dart';
import 'package:rider/src/features/orders/presentation/cubit/rider_orders_cubit.dart';
import 'package:rider/src/presentation/bloc/rider_bloc.dart';
import 'package:rider/src/presentation/router/rider_routes.dart';
import 'package:shared/shared.dart';

class RiderModule extends Module<RouteBase> {
  const RiderModule();

  @override
  Set<RouteBase> routes(DI injector) => {
    ShellRoute(
      builder: (context, state, child) => MultiRepositoryProvider(
        providers: [
          RepositoryProvider<RiderRemoteDataSource>(
            create: (context) =>
                RiderRemoteDataSourceImpl(injector.get<GraphQLService>()),
          ),
          RepositoryProvider<RiderRepository>(
            create: (context) =>
                RiderRepositoryImpl(context.read<RiderRemoteDataSource>()),
          ),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider<RiderBloc>(
              create: (context) => RiderBloc(
                context.read<RiderRepository>(),
                RiderSessionManager(
                  context.read<RiderRepository>(),
                  injector.get<AppEventStreamManager>(),
                ),
                injector.get<LogoutUseCase>(),
              ),
            ),
            BlocProvider<RiderOrdersCubit>(
              create: (context) => RiderOrdersCubit(
                context.read<RiderRepository>(),
              ),
            ),
          ],
          child: ToastServiceWidget(child: child),
        ),
      ),
      routes: [
        GoRoute(
          path: RiderRoutes.rootPath,
          redirect: (context, state) => const RedirectGuard(
            RiderRoutes.map,
            from: RiderRoutes.rootPath,
          ).redirect(context, state.fullPath),
          routes: riderRoutes,
        ),
      ],
    ),
  };
}
