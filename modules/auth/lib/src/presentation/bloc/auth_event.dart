abstract class AuthEvent {
  const AuthEvent();
}

class AuthLogin extends AuthEvent {
  const AuthLogin({required this.email, required this.password});
  final String email;
  final String password;
}

class AuthSignUp extends AuthEvent {
  const AuthSignUp({required this.email, required this.password, required this.name});
  final String email;
  final String password;
  final String name;
}

class AuthForgotPassword extends AuthEvent {
  const AuthForgotPassword({required this.email});
  final String email;
}

class AuthVerifyOtp extends AuthEvent {
  const AuthVerifyOtp({required this.email, required this.otp});
  final String email;
  final String otp;
}

class AuthResetPassword extends AuthEvent {
  const AuthResetPassword({required this.email, required this.newPassword});
  final String email;
  final String newPassword;
}

class AuthLogout extends AuthEvent {
  const AuthLogout();
}
