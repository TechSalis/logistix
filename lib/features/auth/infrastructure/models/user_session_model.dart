part of '../../domain/entities/user_session.dart';

class AuthUserModel extends AuthUser {
  const AuthUserModel._({
    required super.id,
    required super.isAnonymous,
    required super.role,
    required super.data,
  });

  factory AuthUserModel.fromMap(Map<String, dynamic> json) {
    return AuthUserModel._(
      id: json['id'] as String,
      isAnonymous: json['is_anonymous'] as bool? ?? true,
      role: _roleFromString(json['user_metadata']?['role']),
      data: UserDataModel.fromJson(json),
    );
  }

  static UserRole _roleFromString(String value) {
    switch (value) {
      case 'rider':
        return UserRole.rider;
      case 'company':
        return UserRole.company;
      default:
        return UserRole.customer;
    }
  }

  static String _roleToString(UserRole role) {
    switch (role) {
      case UserRole.rider:
        return 'rider';
      case UserRole.company:
        return 'company';
      default:
        return 'customer';
    }
  }
}

class AuthSessionModel extends AuthSession {
  const AuthSessionModel._({
    required super.refreshToken,
    required super.token,
    required super.expiresAt,
  });

  factory AuthSessionModel.fromMap(Map<String, dynamic> json) {
    return AuthSessionModel._(
      token: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      expiresAt: json['expires_at'] as String,
    );
  }
}
