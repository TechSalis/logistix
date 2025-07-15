import 'package:logistix/features/auth/domain/entities/user_session.dart';

abstract class AuthLocalRepository {
  Future<void> saveSession(AuthSession session);
  Future<AuthSession?> getSession();
  
  Future<void> saveUser(AuthUser user);
  Future<AuthUser?> getUser();

  Future<void> clear();
}