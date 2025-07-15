import 'package:logistix/features/auth/domain/entities/user_data.dart';
import 'package:logistix/features/auth/infrastructure/models/user_data_model.dart';

part '../../infrastructure/models/user_session_model.dart';

enum UserRole { customer, rider, company }

class AuthUser {
  final String id;
  final UserRole role;
  final bool isAnonymous;
  final UserData data;

  const AuthUser({
    required this.id,
    required this.isAnonymous,
    required this.role,
    required this.data,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'is_anonymous': isAnonymous,
      'role': AuthUserModel._roleToString(role),
      'user_metadata': data.toMap(),
    };
  }
}

class AuthSession {
  final String token;
  final String refreshToken;
  final String expiresAt;

  const AuthSession({
    required this.token,
    required this.refreshToken,
    required this.expiresAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'access_token': token,
      'refresh_token': refreshToken,
      'expires_at': expiresAt,
    };
  }
}
