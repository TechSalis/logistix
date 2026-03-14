import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:go_router/go_router.dart';
import 'package:onboarding/src/presentation/pages/dispatcher_onboarding_page.dart';
import 'package:onboarding/src/presentation/pages/rider_onboarding_page.dart';
import 'package:onboarding/src/presentation/pages/role_selection_page.dart';
import 'package:shared/shared.dart';

/// Private relative route paths (without parent prefix)
abstract class _OnboardingPaths {
  static const String roleSelection = 'role-selection';
  static const String riderOnboarding = 'rider';
  static const String dispatcherOnboarding = 'dispatcher';
}

/// Public onboarding module route paths (with /onboarding prefix)
abstract class OnboardingRoutes {
  static const String rootPath = ModuleRoutePaths.onboarding;

  static const String roleSelection =
      '$rootPath/${_OnboardingPaths.roleSelection}';

  static const String riderOnboarding =
      '$rootPath/${_OnboardingPaths.riderOnboarding}';

  static const String dispatcherOnboarding =
      '$rootPath/${_OnboardingPaths.dispatcherOnboarding}';
}

/// Onboarding module route configuration
@internal
List<RouteBase> get onboardingRoutes => [
  GoRoute(
    path: _OnboardingPaths.roleSelection,
    builder: (context, state) => const RoleSelectionPage(),
  ),
  GoRoute(
    path: _OnboardingPaths.riderOnboarding,
    builder: (context, state) => const RiderOnboardingPage(),
  ),
  GoRoute(
    path: _OnboardingPaths.dispatcherOnboarding,
    builder: (context, state) => const DispatcherOnboardingPage(),
  ),
];
