import 'package:hive_flutter/hive_flutter.dart';
import 'package:logistix/core/utils/extensions/hive.dart';
import 'package:logistix/features/auth/domain/entities/user_session.dart';
import 'package:logistix/features/auth/domain/repository/auth_local_repository.dart';

class AuthHiveRepositoryImpl extends AuthLocalRepository {
  Future<Box> get box => Hive.openTrackedBox('auth');

  @override
  Future<void> clear() async => (await box).clear();

  @override
  Future<AuthSession?> getSession() async {
    final session = (await box).get('session');
    if (session == null) return null;
    return AuthSessionModel.fromMap(session);
  }

  @override
  Future<void> saveSession(AuthSession session) async {
    return (await box).put('session', session.toMap());
  }

  @override
  Future<AuthUser?> getUser() async {
    final userdata = (await box).get('user');
    if (userdata == null) return null;
    return AuthUserModel.fromMap(userdata);
  }

  @override
  Future<void> saveUser(AuthUser user) async {
    return (await box).put('user', user.toMap());
  }
}
