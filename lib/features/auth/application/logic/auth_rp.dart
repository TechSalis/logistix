import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logistix/core/services/app_data_cache.dart';
import 'package:logistix/core/services/dio_service.dart';
import 'package:logistix/features/auth/domain/repository/auth_remote_repository.dart';
import 'package:logistix/features/auth/infrastructure/models/auth_dto.dart';
import 'package:logistix/features/auth/infrastructure/repository/auth_remote_repository_impl.dart';
import 'package:logistix/features/auth/infrastructure/repository/auth_local_store.dart';
import 'package:logistix/features/auth/domain/entities/user_session.dart';

final authRepoProvider = Provider.autoDispose<AuthRepository>(
  (ref) => AuthRepositoryImpl(client: DioClient.instance),
);

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
    final session = AuthLocalStore.instance.getSession();
    if (session != null) DioClient.updateSession(session);

    final user = AuthLocalStore.instance.getUser();
    if (user == null) {
      return const AuthLoggedOutState();
    } else {
      return AuthLoggedInState(user: user);
    }
  }

  bool canLoginAnonymously() {
    return ref.read(appCacheProvider).isFirstLogin &&
        AuthLocalStore.instance.getSession() == null;
  }

  Future loginAnonymously() async {
    final response = await ref
        .read(authRepoProvider)
        .loginAnonymously(UserRole.customer);
    response.ifAny(success: _saveLoginResponse);
  }

  Future loginWithPassword(LoginData data) async {
    final response = await ref.read(authRepoProvider).login(data);
    response.ifAny(success: _saveLoginResponse);
  }

  void _saveLoginResponse(AuthLoginResponse data) {
    state = AuthLoggedInState(user: data.user);
    AuthLocalStore.instance.saveSession(data.session);
  }

  Future logout() async {
    final response = await ref.read(authRepoProvider).logout();
    response.ifAny(
      success: (_) {
        DioClient.updateSession(null);
        return state = const AuthLoggedOutState();
      },
    );
  }
}

final authProvider = NotifierProvider.autoDispose(AuthNotifier.new);
