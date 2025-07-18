part of '../../domain/entities/user_session.dart';

class AuthUserModel extends AuthUser {
  const AuthUserModel._({
    required super.id,
    required super.isAnonymous,
    required super.role,
    required super.data,
  });

  factory AuthUserModel.fromJson(Map<String, dynamic> json) {
    return AuthUserModel._(
      id: json['id'] as String,
      isAnonymous: json['is_anonymous'] as bool? ?? true,
      role: UserRole.values.byName(json['user_metadata']?['role']),
      data: UserDataModel.fromJson(json),
    );
  }
}

class AuthSessionModel extends AuthSession {
  const AuthSessionModel._({
    required super.refreshToken,
    required super.token,
    required super.expiresAt,
  });

  factory AuthSessionModel.fromJson(Map<String, dynamic> json) {
    return AuthSessionModel._(
      token: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      expiresAt: json['expires_at'] as int,
    );
  }
}
