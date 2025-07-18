import 'package:logistix/features/auth/domain/entities/user_session.dart';

class AuthLoginResponse {
  final AuthUser user;
  final AuthSession session;

  const AuthLoginResponse({required this.user, required this.session});

  factory AuthLoginResponse.fromJson(Map<String, dynamic> json) {
    return AuthLoginResponse(
      user: AuthUserModel.fromJson(json['user']),
      session: AuthSessionModel.fromJson(json['session']),
    );
  }
}

class LoginData {
  final String email;
  final String password;
  final Map<String, dynamic>? userData;

  const LoginData({required this.email, required this.password, this.userData});

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      if (userData != null) 'user_metadata': userData,
    };
  }
}
