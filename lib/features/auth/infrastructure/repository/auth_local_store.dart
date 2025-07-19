import 'package:logistix/features/auth/domain/entities/user_session.dart';
import 'package:logistix/features/auth/domain/repository/auth_local_repository.dart';
import 'package:logistix/features/auth/infrastructure/repository/auth_hive_local_repository_impl.dart';

class AuthLocalStore implements AuthLocalRepository {
  AuthLocalStore._internal();
  static final AuthLocalStore instance = AuthLocalStore._internal();

  //TODO: Use SecureStorage
  final AuthLocalRepository _impl = AuthHiveLocalRepositoryImpl();

  @override
  Future<void> clear() => _impl.clear();

  @override
  AuthSession? getSession() => _impl.getSession();

  @override
  AuthUser? getUser() => _impl.getUser();

  @override
  Future<void> saveSession(AuthSession session) => _impl.saveSession(session);

  @override
  Future<void> saveUser(AuthUser user) => _impl.saveUser(user);
}
