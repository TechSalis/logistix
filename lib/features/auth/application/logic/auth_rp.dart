import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logistix/features/auth/application/logic/auth_session.dart';
import 'package:logistix/features/auth/domain/entities/user_session.dart';

sealed class AuthState {
  const AuthState();

  bool get isLoggedIn => this is AuthLoggedInState;
  bool get isLoggedOut => this is AuthLoggedOutState;
}

final class AuthUnknownState extends AuthState {
  const AuthUnknownState();
}

final class AuthLoggedOutState extends AuthState {
  const AuthLoggedOutState();
}

final class AuthLoggedInState extends AuthState {
  final AuthUser user;
  AuthLoggedInState({required this.user});
}

class AuthNotifier extends AutoDisposeNotifier<AuthState> {
  @override
  AuthState build() {
    getCachedUser();
    return const AuthUnknownState();
  }

  Future getCachedUser() async {
    final user = await AuthLocalStore.instance.getUser();
    if (user == null) {
      state = const AuthLoggedOutState();
    } else {
      state = AuthLoggedInState(user: user);
    }
  }

  // Future cacheRemoteUser() async {
  //   state = AuthLoggedInState(user: user);
  //   await AuthLocalStore.instance.saveUser();
  // }

  Future logOut() async {
    final user = await AuthLocalStore.instance.clear();
    state = const AuthLoggedOutState();
  }
}

final authProvider = NotifierProvider.autoDispose(AuthNotifier.new);
