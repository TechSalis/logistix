abstract class AuthState {
  const AuthState();

  const factory AuthState.initial() = AuthInitial;
  
  // Login
  const factory AuthState.loginLoading() = AuthLoginLoading;
  const factory AuthState.loginSuccess() = AuthLoginSuccess;
  const factory AuthState.loginError(String message) = AuthLoginError;

  // Sign Up
  const factory AuthState.signUpLoading() = AuthSignUpLoading;
  const factory AuthState.signUpSuccess() = AuthSignUpSuccess;
  const factory AuthState.signUpError(String message) = AuthSignUpError;

  // Forgot Password
  const factory AuthState.forgotPasswordLoading() = AuthForgotPasswordLoading;
  const factory AuthState.otpSent({required String email}) = AuthOtpSent;
  const factory AuthState.forgotPasswordError(String message) = AuthForgotPasswordError;

  // OTP Verification
  const factory AuthState.verifyOtpLoading() = AuthVerifyOtpLoading;
  const factory AuthState.otpVerified({required String email}) = AuthOtpVerified;
  const factory AuthState.verifyOtpError(String message) = AuthVerifyOtpError;

  // Password Reset
  const factory AuthState.resetPasswordLoading() = AuthResetPasswordLoading;
  const factory AuthState.passwordResetSuccess() = AuthPasswordResetSuccess;
  const factory AuthState.resetPasswordError(String message) = AuthResetPasswordError;

  T? whenOrNull<T>({
    T Function()? initial,
    T Function()? loginLoading,
    T Function()? loginSuccess,
    T Function(String message)? loginError,
    T Function()? signUpLoading,
    T Function()? signUpSuccess,
    T Function(String message)? signUpError,
    T Function()? forgotPasswordLoading,
    T Function(String email)? otpSent,
    T Function(String message)? forgotPasswordError,
    T Function()? verifyOtpLoading,
    T Function(String email)? otpVerified,
    T Function(String message)? verifyOtpError,
    T Function()? resetPasswordLoading,
    T Function()? passwordResetSuccess,
    T Function(String message)? resetPasswordError,
  }) {
    if (this is AuthInitial) return initial?.call();
    if (this is AuthLoginLoading) return loginLoading?.call();
    if (this is AuthLoginSuccess) return loginSuccess?.call();
    if (this is AuthLoginError) return loginError?.call((this as AuthLoginError).message);
    if (this is AuthSignUpLoading) return signUpLoading?.call();
    if (this is AuthSignUpSuccess) return signUpSuccess?.call();
    if (this is AuthSignUpError) return signUpError?.call((this as AuthSignUpError).message);
    if (this is AuthForgotPasswordLoading) return forgotPasswordLoading?.call();
    if (this is AuthOtpSent) return otpSent?.call((this as AuthOtpSent).email);
    if (this is AuthForgotPasswordError) return forgotPasswordError?.call((this as AuthForgotPasswordError).message);
    if (this is AuthVerifyOtpLoading) return verifyOtpLoading?.call();
    if (this is AuthOtpVerified) return otpVerified?.call((this as AuthOtpVerified).email);
    if (this is AuthVerifyOtpError) return verifyOtpError?.call((this as AuthVerifyOtpError).message);
    if (this is AuthResetPasswordLoading) return resetPasswordLoading?.call();
    if (this is AuthPasswordResetSuccess) return passwordResetSuccess?.call();
    if (this is AuthResetPasswordError) return resetPasswordError?.call((this as AuthResetPasswordError).message);
    return null;
  }

  T maybeWhen<T>({
    required T Function() orElse, T Function()? initial,
    T Function()? loginLoading,
    T Function()? loginSuccess,
    T Function(String message)? loginError,
    T Function()? signUpLoading,
    T Function()? signUpSuccess,
    T Function(String message)? signUpError,
    T Function()? forgotPasswordLoading,
    T Function(String email)? otpSent,
    T Function(String message)? forgotPasswordError,
    T Function()? verifyOtpLoading,
    T Function(String email)? otpVerified,
    T Function(String message)? verifyOtpError,
    T Function()? resetPasswordLoading,
    T Function()? passwordResetSuccess,
    T Function(String message)? resetPasswordError,
  }) {
    return whenOrNull(
      initial: initial,
      loginLoading: loginLoading,
      loginSuccess: loginSuccess,
      loginError: loginError,
      signUpLoading: signUpLoading,
      signUpSuccess: signUpSuccess,
      signUpError: signUpError,
      forgotPasswordLoading: forgotPasswordLoading,
      otpSent: otpSent,
      forgotPasswordError: forgotPasswordError,
      verifyOtpLoading: verifyOtpLoading,
      otpVerified: otpVerified,
      verifyOtpError: verifyOtpError,
      resetPasswordLoading: resetPasswordLoading,
      passwordResetSuccess: passwordResetSuccess,
      resetPasswordError: resetPasswordError,
    ) ?? orElse();
  }
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoginLoading extends AuthState {
  const AuthLoginLoading();
}

class AuthLoginSuccess extends AuthState {
  const AuthLoginSuccess();
}

class AuthLoginError extends AuthState {
  const AuthLoginError(this.message);
  final String message;
}

class AuthSignUpLoading extends AuthState {
  const AuthSignUpLoading();
}

class AuthSignUpSuccess extends AuthState {
  const AuthSignUpSuccess();
}

class AuthSignUpError extends AuthState {
  const AuthSignUpError(this.message);
  final String message;
}

class AuthForgotPasswordLoading extends AuthState {
  const AuthForgotPasswordLoading();
}

class AuthOtpSent extends AuthState {
  const AuthOtpSent({required this.email});
  final String email;
}

class AuthForgotPasswordError extends AuthState {
  const AuthForgotPasswordError(this.message);
  final String message;
}

class AuthVerifyOtpLoading extends AuthState {
  const AuthVerifyOtpLoading();
}

class AuthOtpVerified extends AuthState {
  const AuthOtpVerified({required this.email});
  final String email;
}

class AuthVerifyOtpError extends AuthState {
  const AuthVerifyOtpError(this.message);
  final String message;
}

class AuthResetPasswordLoading extends AuthState {
  const AuthResetPasswordLoading();
}

class AuthPasswordResetSuccess extends AuthState {
  const AuthPasswordResetSuccess();
}

class AuthResetPasswordError extends AuthState {
  const AuthResetPasswordError(this.message);
  final String message;
}
