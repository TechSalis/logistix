import 'package:bootstrap/interfaces/http/token_store.dart';
import 'package:bootstrap/interfaces/modules/modules.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:onboarding/onboarding.dart';
import 'package:onboarding/src/data/datasources/company_remote_datasource.dart';
import 'package:onboarding/src/data/datasources/onboarding_remote_datasource.dart';
import 'package:onboarding/src/data/repositories/company_repository_impl.dart';
import 'package:onboarding/src/data/repositories/onboarding_repository_impl.dart';
import 'package:onboarding/src/domain/repositories/company_repository.dart';
import 'package:onboarding/src/domain/repositories/onboarding_repository.dart';
import 'package:onboarding/src/presentation/router/onboarding_routes.dart';
import 'package:shared/shared.dart';

class OnboardingModule extends Module<RouteBase> {
  const OnboardingModule();

  @override
  Set<RouteBase> routes(DI injector) => {
    ShellRoute(
      builder: (context, state, child) => MultiRepositoryProvider(
        providers: [
          RepositoryProvider<CompanyRemoteDataSource>(
            create: (context) => CompanyRemoteDataSourceImpl(
              injector.get<GraphQLService>(),
            ),
          ),
          RepositoryProvider<CompanyRepository>(
            create: (context) =>
                CompanyRepositoryImpl(context.read<CompanyRemoteDataSource>()),
          ),
          RepositoryProvider<OnboardingRemoteDataSource>(
            create: (context) => OnboardingRemoteDataSourceImpl(
              injector.get<GraphQLService>(),
            ),
          ),
          RepositoryProvider<OnboardingRepository>(
            create: (context) => OnboardingRepositoryImpl(
              context.read<OnboardingRemoteDataSource>(),
              injector.get<TokenStore>(),
              injector.get<UserStore>(),
            ),
          ),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider<OnboardingBloc>(
              create: (context) {
                return OnboardingBloc(
                  context.read<OnboardingRepository>(),
                  injector.get<AuthStatusRepository>(),
                );
              },
            ),
            BlocProvider<AddressCubit>(
              create: (context) => AddressCubit(injector.get<PlacesService>()),
            ),
          ],
          child: BlocListener<OnboardingBloc, OnboardingState>(
            listener: (context, state) {
              state.mapOrNull(
                rider: (_) => context.go(OnboardingRoutes.completeOnboarding),
                dispatcher: (_) {
                  context.go(OnboardingRoutes.completeOnboarding);
                },
              );
            },
            child: ToastServiceWidget(child: child),
          ),
        ),
      ),
      routes: [
        GoRoute(
          path: OnboardingRoutes.rootPath,
          redirect: (context, state) => const RedirectGuard(
            OnboardingRoutes.roleSelection,
            from: OnboardingRoutes.rootPath,
          ).redirect(context, state.fullPath),
          routes: onboardingRoutes,
        ),
      ],
    ),
  };
}
