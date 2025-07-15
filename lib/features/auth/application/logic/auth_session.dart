import 'package:logistix/features/auth/domain/entities/user_session.dart';
import 'package:logistix/features/auth/domain/repository/auth_local_repository.dart';
import 'package:logistix/features/auth/infrastructure/repository/auth_hive_repository_impl.dart';

class AuthLocalStore implements AuthLocalRepository {
  AuthLocalStore._internal();
  static final instance = AuthLocalStore._internal();

  final AuthLocalRepository _impl = AuthHiveRepositoryImpl();

  @override
  Future<void> clear() => _impl.clear();

  @override
  Future<AuthSession?> getSession() => _impl.getSession();

  @override
  Future<AuthUser?> getUser() => _impl.getUser();

  @override
  Future<void> saveSession(AuthSession session) => _impl.saveSession(session);

  @override
  Future<void> saveUser(AuthUser user) => _impl.saveUser(user);
}
