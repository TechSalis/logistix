import 'package:bootstrap/core.dart';
import 'package:bootstrap/interfaces/modules/modules.dart';
import 'package:dispatcher/src/data/datasources/company_remote_datasource.dart';
import 'package:dispatcher/src/data/datasources/metrics_remote_datasource.dart';
import 'package:dispatcher/src/data/datasources/order_remote_datasource.dart';
import 'package:dispatcher/src/data/datasources/rider_remote_datasource.dart';
import 'package:dispatcher/src/data/repositories/company_repository_impl.dart';
import 'package:dispatcher/src/data/repositories/metrics_repository_impl.dart';
import 'package:dispatcher/src/data/repositories/order_repository_impl.dart';
import 'package:dispatcher/src/data/repositories/rider_repository_impl.dart';
import 'package:dispatcher/src/domain/repositories/company_repository.dart';
import 'package:dispatcher/src/domain/repositories/metrics_repository.dart';
import 'package:dispatcher/src/domain/repositories/order_repository.dart';
import 'package:dispatcher/src/domain/repositories/rider_repository.dart';
import 'package:dispatcher/src/domain/usecases/manage_dispatcher_session_usecase.dart';
import 'package:dispatcher/src/features/more/presentation/cubit/more_cubit.dart';
import 'package:dispatcher/src/features/orders/presentation/cubit/create_order_cubit.dart';
import 'package:dispatcher/src/features/orders/presentation/cubit/metrics_cubit.dart';
import 'package:dispatcher/src/features/orders/presentation/cubit/orders_cubit.dart';
import 'package:dispatcher/src/features/riders/presentation/cubit/riders_cubit.dart';
import 'package:dispatcher/src/presentation/router/dispatcher_routes.dart';
import 'package:dispatcher/src/presentation/widgets/dispatcher_session_provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared/shared.dart';

class DispatcherModule extends Module<RouteBase> {
  const DispatcherModule();

  @override
  Set<RouteBase> routes(DI injector) => {
    ShellRoute(
      builder: (context, state, child) => MultiRepositoryProvider(
        providers: [
          RepositoryProvider<OrderRepository>(
            create: (context) => OrderRepositoryImpl(
              OrderRemoteDataSourceImpl(injector.get<GraphQLService>()),
            ),
          ),
          RepositoryProvider<RiderRepository>(
            create: (context) => RiderRepositoryImpl(
              RiderRemoteDataSourceImpl(injector.get<GraphQLService>()),
            ),
          ),
          RepositoryProvider<MetricsRepository>(
            create: (context) => MetricsRepositoryImpl(
              MetricsRemoteDataSourceImpl(injector.get<GraphQLService>()),
            ),
          ),
          RepositoryProvider<CompanyRepository>(
            create: (context) => CompanyRepositoryImpl(
              CompanyRemoteDataSourceImpl(injector.get<GraphQLService>()),
            ),
          ),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => CreateOrderCubit(
                context.read<OrderRepository>(),
                context.read<RiderRepository>(),
              ),
            ),
            BlocProvider<OrdersCubit>(
              create: (context) => OrdersCubit(context.read<OrderRepository>()),
            ),
            BlocProvider<RidersCubit>(
              create: (context) => RidersCubit(context.read<RiderRepository>()),
            ),
            BlocProvider<MetricsCubit>(
              create: (context) {
                return MetricsCubit(context.read<MetricsRepository>());
              },
            ),
            BlocProvider<MoreCubit>(
              create: (context) => MoreCubit(
                injector.get<LogoutUseCase>(),
                injector.get<UserStore>(),
                context.read<CompanyRepository>(),
              ),
            ),
          ],
          child: DispatcherSessionProvider(
            sessionManager: DispatcherSessionManager(
              injector.get<AppEventStreamManager>(),
            ),
            userStore: injector.get<UserStore>(),
            child: ToastServiceWidget(child: child),
          ),
        ),
      ),
      routes: [
        GoRoute(
          path: DispatcherRoutes.rootPath,
          redirect: (context, state) => const RedirectGuard(
            DispatcherRoutes.orders,
            from: DispatcherRoutes.rootPath,
          ).redirect(context, state.fullPath),
          routes: dispatcherRoutes,
        ),
      ],
    ),
  };
}
