import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_event.freezed.dart';

@freezed
class AuthEvent with _$AuthEvent {
  const factory AuthEvent.login({
    required String email,
    required String password,
  }) = _Login;
  const factory AuthEvent.signUp({
    required String email,
    required String password,
    required String name,
  }) = _SignUp;
  const factory AuthEvent.forgotPassword({required String email}) =
      _ForgotPassword;
  const factory AuthEvent.verifyOtp({
    required String email,
    required String otp,
  }) = _VerifyOtp;
  const factory AuthEvent.resetPassword({
    required String email,
    required String newPassword,
  }) = _ResetPassword;
  const factory AuthEvent.logout() = _Logout;
}
