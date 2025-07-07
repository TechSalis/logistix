import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logistix/features/auth/domain/entities/user.dart';
import 'package:logistix/features/auth/domain/entities/user_data.dart';

sealed class AuthState {
  bool get isLoggedIn => this is AuthLoggedIn;
  bool get isLoggedOut => this is AuthLoggedOut;
}

final class AuthLoggedOut extends AuthState {}

final class AuthLoggedIn extends AuthState {
  final User user;
  AuthLoggedIn({required this.user});
}

class AuthNotifier extends AutoDisposeNotifier<AuthState> {
  @override
  AuthState build() {
    return AuthLoggedIn(
      user: const User(
        id: 'id',
        isAnonymous: true,
        role: UserRole.customer,
        data: UserData(id: ''),
      ),
    );
    // return AuthLoggedOut(); //TODO
  }
}

final authProvider = NotifierProvider.autoDispose(AuthNotifier.new);
