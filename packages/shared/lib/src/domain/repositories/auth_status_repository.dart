import 'dart:async';
import 'package:shared/shared.dart';

/// The overall authentication status of the application.
enum AuthStatus { unknown, authenticated, unauthenticated, onboarding }

/// A session object that encapsulates the current status and the associated user.
class AuthSession {
  const AuthSession({this.status = AuthStatus.unknown, this.user});

  const AuthSession.unknown() : status = AuthStatus.unknown, user = null;
  const AuthSession.unauthenticated()
    : status = AuthStatus.unauthenticated,
      user = null;
  const AuthSession.authenticated(User this.user)
    : status = AuthStatus.authenticated;
  const AuthSession.onboarding(User this.user) : status = AuthStatus.onboarding;

  final AuthStatus status;
  final User? user;

  @override
  String toString() => 'AuthSession(status: $status, user: ${user?.id})';
}

/// Global repository for managing the application's core session state.
///
/// This acts as the Single Source of Truth for "who is the current user"
/// and "what is the session status".
abstract class AuthStatusRepository {
  /// Reactive stream of the current session state.
  Stream<AuthSession> get session;

  /// Updates the status to [AuthStatus.authenticated].
  void setAuthenticated(User user);

  /// Updates the status to [AuthStatus.unauthenticated].
  void setUnauthenticated();

  /// Fetches the initial session state from storage.
  Future<void> initialize();

  /// Clean up resources.
  void dispose();
}

class AuthStatusRepositoryImpl implements AuthStatusRepository {
  AuthStatusRepositoryImpl(this._userStore)
    : _controller = StreamController<AuthSession>.broadcast();

  final UserStore _userStore;
  final StreamController<AuthSession> _controller;
  AuthSession _currentSession = const AuthSession.unknown();

  @override
  Stream<AuthSession> get session => _controller.stream;

  @override
  Future<void> initialize() async {
    final user = await _userStore.getUser();
    if (user != null) {
      if (user.isOnboarded && user.role != null) {
        _update(AuthSession.authenticated(user));
      } else {
        _update(AuthSession.onboarding(user));
      }
    } else {
      _update(const AuthSession.unauthenticated());
    }
  }

  @override
  void setAuthenticated(User user) {
    if (user.isOnboarded && user.role != null) {
      _update(AuthSession.authenticated(user));
    } else {
      _update(AuthSession.onboarding(user));
    }
  }

  @override
  void setUnauthenticated() {
    _update(const AuthSession.unauthenticated());
  }

  void _update(AuthSession session) {
    if (_currentSession.status == session.status &&
        _currentSession.user?.id == session.user?.id) {
      return;
    }
    _currentSession = session;
    _controller.add(session);
  }

  @override
  void dispose() {
    _controller.close();
  }
}
