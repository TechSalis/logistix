import 'package:shared/shared.dart';

abstract class AppState {
  const AppState();

  const factory AppState.initializing() = AppInitializing;
  const factory AppState.unauthenticated() = AppUnauthenticated;
  const factory AppState.needsOnboarding({required User user}) = AppNeedsOnboarding;
  const factory AppState.authenticated({
    required User user,
    required UserRole role,
  }) = AppAuthenticated;
  const factory AppState.error(String message) = AppInitError;

  bool get isInitializing => this is AppInitializing;

  T? whenOrNull<T>({
    T Function()? initializing,
    T Function()? unauthenticated,
    T Function(User user)? needsOnboarding,
    T Function(User user, UserRole role)? authenticated,
    T Function(String message)? error,
  }) {
    if (this is AppInitializing) return initializing?.call();
    if (this is AppUnauthenticated) return unauthenticated?.call();
    if (this is AppNeedsOnboarding) return needsOnboarding?.call((this as AppNeedsOnboarding).user);
    if (this is AppAuthenticated) {
      final state = this as AppAuthenticated;
      return authenticated?.call(state.user, state.role);
    }
    if (this is AppInitError) return error?.call((this as AppInitError).message);
    return null;
  }
}

class AppInitializing extends AppState {
  const AppInitializing();
}

class AppUnauthenticated extends AppState {
  const AppUnauthenticated();
}

class AppNeedsOnboarding extends AppState {
  const AppNeedsOnboarding({required this.user});
  final User user;
}

class AppAuthenticated extends AppState {
  const AppAuthenticated({required this.user, required this.role});
  final User user;
  final UserRole role;
}

class AppInitError extends AppState {
  const AppInitError(this.message);
  final String message;
}
