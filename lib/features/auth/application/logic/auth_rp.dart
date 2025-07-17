import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logistix/core/services/auth_store_service.dart';
import 'package:logistix/features/auth/domain/entities/user_session.dart';

sealed class AuthState {
  const AuthState();

  bool get isLoggedIn => this is AuthLoggedInState;
  bool get isLoggedOut => this is AuthLoggedOutState;
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
    final user = AuthLocalStore.instance.getUser();
    if (user == null) {
      return const AuthLoggedOutState();
    } else {
      return AuthLoggedInState(user: user);
    }
  }

  Future logOut() async {
    final user = await AuthLocalStore.instance.clear();
    state = const AuthLoggedOutState();
  }
}

final authProvider = NotifierProvider.autoDispose(AuthNotifier.new);
