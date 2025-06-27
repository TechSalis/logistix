import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logistix/features/customer_auth/domain/entities/customer.dart';

sealed class AuthState {
  bool get isLoggedIn => this is AuthLoggedIn;
  bool get isLoggedOut => this is AuthLoggedOut;
}

final class AuthLoggedOut extends AuthState {}

final class AuthLoggedIn extends AuthState {
  final Customer user;
  AuthLoggedIn({required this.user});
}

class AuthNotifier extends AutoDisposeNotifier<AuthState> {
  @override
  AuthState build() {
    return AuthLoggedIn(user: Customer(id: 'customer_id', name: 'Eric O'));
    // return AuthLoggedOut(); //TODO
  }
}

final authProvider = NotifierProvider.autoDispose(AuthNotifier.new);
