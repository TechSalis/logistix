import 'dart:async';

import 'package:logistix/features/auth/domain/entities/user_session.dart';

abstract class AuthLocalRepository {
  Future<void> saveSession(AuthSession session);
  AuthSession? getSession();
  
  Future<void> saveUser(AuthUser user);
  AuthUser? getUser();

  Future<void> clear();
}