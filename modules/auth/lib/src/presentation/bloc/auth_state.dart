import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_state.freezed.dart';

@freezed
abstract class AuthState with _$AuthState {
  const factory AuthState.initial() = _Initial;

  // Login States
  const factory AuthState.loginLoading() = _LoginLoading;
  const factory AuthState.loginSuccess() = _LoginSuccess;
  const factory AuthState.loginError(String message) = _LoginError;

  // Sign Up States
  const factory AuthState.signUpLoading() = _SignUpLoading;
  const factory AuthState.signUpSuccess() = _SignUpSuccess;
  const factory AuthState.signUpError(String message) = _SignUpError;

  // Forgot Password States
  const factory AuthState.forgotPasswordLoading() = _ForgotPasswordLoading;
  const factory AuthState.otpSent({required String email}) = _OtpSent;
  const factory AuthState.forgotPasswordError(String message) = _ForgotPasswordError;

  // OTP Verification States
  const factory AuthState.verifyOtpLoading() = _VerifyOtpLoading;
  const factory AuthState.otpVerified({required String email}) = _OtpVerified;
  const factory AuthState.verifyOtpError(String message) = _VerifyOtpError;

  // Password Reset States
  const factory AuthState.resetPasswordLoading() = _ResetPasswordLoading;
  const factory AuthState.passwordResetSuccess() = _PasswordResetSuccess;
  const factory AuthState.resetPasswordError(String message) = _ResetPasswordError;
}
