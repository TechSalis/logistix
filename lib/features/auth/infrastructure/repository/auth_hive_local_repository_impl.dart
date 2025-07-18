import 'package:hive_flutter/hive_flutter.dart';
import 'package:logistix/core/constants/hive_constants.dart';
import 'package:logistix/features/auth/domain/entities/user_session.dart';
import 'package:logistix/features/auth/domain/repository/auth_local_repository.dart';

class AuthHiveLocalRepositoryImpl extends AuthLocalRepository {
  Box get box => Hive.box(HiveConstants.auth);

  @override
  Future<void> clear() async => box.clear();

  @override
  AuthSession? getSession() {
    final session = box.get('session');
    if (session == null) return null;
    return AuthSessionModel.fromJson(Map.from(session));
  }

  @override
  Future<void> saveSession(AuthSession session) async {
    return box.put('session', session.toJson());
  }

  @override
  AuthUser? getUser() {
    final userdata = box.get('user');
    if (userdata == null) return null;
    return AuthUserModel.fromJson(userdata);
  }

  @override
  Future<void> saveUser(AuthUser user) async {
    return box.put('user', user.toJson());
  }
}
