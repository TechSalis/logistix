import 'package:go_router/go_router.dart';
import 'package:onboarding/src/presentation/pages/complete_onboarding_page.dart';
import 'package:onboarding/src/presentation/pages/dispatcher_onboarding_page.dart';
import 'package:onboarding/src/presentation/pages/rider_onboarding_page.dart';
import 'package:onboarding/src/presentation/pages/role_selection_page.dart';
import 'package:shared/shared.dart';

/// Private relative route paths (without parent prefix)
abstract class _OnboardingPaths {
  static const String roleSelection = 'role-selection';
  static const String riderOnboarding = 'rider';
  static const String dispatcherOnboarding = 'dispatcher';
  static const String completeOnboarding = 'complete';
}

/// Public onboarding module route paths (with /onboarding prefix)
abstract class OnboardingRoutes {
  static const String rootPath = ModuleRoutePaths.onboarding;

  static const String roleSelection =
      '$rootPath/${_OnboardingPaths.roleSelection}';

  static const String riderOnboarding =
      '$roleSelection/${_OnboardingPaths.riderOnboarding}';

  static const String dispatcherOnboarding =
      '$roleSelection/${_OnboardingPaths.dispatcherOnboarding}';

  static const String completeOnboarding =
      '$roleSelection/${_OnboardingPaths.completeOnboarding}';
}

/// Onboarding module route configuration
List<RouteBase> get onboardingRoutes => [
  GoRoute(
    path: _OnboardingPaths.roleSelection,
    builder: (context, state) => const RoleSelectionPage(),
    routes: [
      GoRoute(
        path: _OnboardingPaths.riderOnboarding,
        builder: (context, state) => const RiderOnboardingPage(),
      ),
      GoRoute(
        path: _OnboardingPaths.dispatcherOnboarding,
        builder: (context, state) => const DispatcherOnboardingPage(),
      ),
      GoRoute(
        path: _OnboardingPaths.completeOnboarding,
        builder: (context, state) => const CompleteOnboardingPage(),
      ),
    ],
  ),
];
