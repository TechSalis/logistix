import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shared/shared.dart';

part 'auth_state.freezed.dart';

@freezed
abstract class AuthState with _$AuthState {
  const factory AuthState.initial() = _Initial;
  const factory AuthState.loading() = _Loading;
  const factory AuthState.authenticated({required User user}) = _Authenticated;
  const factory AuthState.pendingOnboarding({required User user}) =
      _PendingRoleSelection;
  const factory AuthState.otpSent({required String email}) = _OtpSent;
  const factory AuthState.otpVerified({required String email}) = _OtpVerified;
  const factory AuthState.passwordResetSuccess() = _PasswordResetSuccess;
  const factory AuthState.unauthenticated({String? message}) = _Unauthenticated;
}
