import 'package:auth/src/presentation/pages/forgot_password_page.dart';
import 'package:auth/src/presentation/pages/login_page.dart';
import 'package:auth/src/presentation/pages/reset_password_page.dart';
import 'package:auth/src/presentation/pages/sign_up_page.dart';
import 'package:auth/src/presentation/pages/verify_otp_page.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:go_router/go_router.dart';
import 'package:shared/shared.dart';

/// Private relative route paths (without parent prefix)
abstract class _AuthPaths {
  static const String login = '/login';
  static const String signUp = '/sign-up';
  static const String forgotPassword = '/forgot-password';
  static const String verifyOtp = '/verify-otp';
  static const String resetPassword = '/reset-password';
}

/// Public auth module route paths (with /auth prefix)
abstract class AuthRoutes {
  static const String rootPath = ModuleRoutePaths.auth;

  static const String login = '$rootPath${_AuthPaths.login}';
  static const String signUp = '$rootPath${_AuthPaths.signUp}';
  static const String forgotPassword = '$rootPath${_AuthPaths.forgotPassword}';
  static const String verifyOtp = '$rootPath${_AuthPaths.verifyOtp}';
  static const String resetPassword = '$rootPath${_AuthPaths.resetPassword}';
}

/// Auth module route configuration
@internal
List<RouteBase> get authRoutes => [
  GoRoute(
    path: _AuthPaths.login,
    builder: (context, state) => const LoginPage(),
  ),
  GoRoute(
    path: _AuthPaths.signUp,
    builder: (context, state) => const SignUpPage(),
  ),
  GoRoute(
    path: _AuthPaths.forgotPassword,
    builder: (context, state) => const ForgotPasswordPage(),
  ),
  GoRoute(
    path: _AuthPaths.verifyOtp,
    builder: (context, state) {
      final email = state.uri.queryParameters['email'] ?? '';
      return VerifyOtpPage(email: email);
    },
  ),
  GoRoute(
    path: _AuthPaths.resetPassword,
    builder: (context, state) {
      final email = state.uri.queryParameters['email'] ?? '';
      return ResetPasswordPage(email: email);
    },
  ),
];
