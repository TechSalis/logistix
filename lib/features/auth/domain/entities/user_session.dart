import 'package:logistix/features/auth/domain/entities/user_data.dart';
import 'package:logistix/features/auth/infrastructure/models/user_data_model.dart';

part '../../infrastructure/models/user_session_model.dart';

enum UserRole { customer, rider, company }

class AuthUser {
  final String id;
  final bool isAnonymous;
  final UserData data;

  const AuthUser({
    required this.id,
    required this.isAnonymous,
    required this.data,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'is_anonymous': isAnonymous,
      'user_metadata': data.toJson(),
    };
  }
}

class AuthSession {
  final String token;
  final String refreshToken;
  final int expiresAt;

  const AuthSession({
    required this.token,
    required this.refreshToken,
    required this.expiresAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'access_token': token,
      'refresh_token': refreshToken,
      'expires_at': expiresAt,
    };
  }
}
