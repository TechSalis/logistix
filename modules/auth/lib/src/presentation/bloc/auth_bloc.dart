import 'dart:async';

import 'package:auth/src/domain/repositories/auth_repository.dart';
import 'package:auth/src/presentation/bloc/auth_event.dart';
import 'package:auth/src/presentation/bloc/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared/shared.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(
    this._authRepository,
    this._userStore,
    this._logoutUseCase,
    AuthStatusRepository authStatus,
  ) : _authStatus = authStatus,
      super(const AuthState.initial()) {
    on<AuthEvent>((event, emit) async {
      await event.when(
        login: (email, password) => _onLogin(email, password, emit),
        signUp: (email, password, name) =>
            _onSignUp(email, password, name, emit),
        forgotPassword: (email) => _onForgotPassword(email, emit),
        verifyOtp: (email, otp) => _onVerifyOtp(email, otp, emit),
        resetPassword: (email, newPassword) =>
            _onResetPassword(email, newPassword, emit),
        logout: () => _onLogout(emit),
      );
    });
  }
  final AuthRepository _authRepository;
  final UserStore _userStore;
  final LogoutUseCase _logoutUseCase;
  final AuthStatusRepository _authStatus;
  Future<void> _onLogin(
    String email,
    String password,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loginLoading());
    final result = await _authRepository.login(email, password);
    await result.map<FutureOr<void>>(
      (error) => emit(
        AuthState.loginError(error.message ?? 'Invalid credentials. Please check your email and password.'),
      ),
      (user) async {
        await _userStore.saveUser(user);
        _authStatus.setAuthenticated(user);
        emit(const AuthState.loginSuccess());
      },
    );
  }

  Future<void> _onSignUp(
    String email,
    String password,
    String name,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.signUpLoading());
    final result = await _authRepository.signUp(
      email: email,
      password: password,
      name: name,
    );

    await result.map(
      (error) {
        emit(
          AuthState.signUpError(
            error.message ?? 'Failed to create account. Please try again.',
          ),
        );
      },
      (user) async {
        await _userStore.saveUser(user);
        _authStatus.setAuthenticated(user);
        emit(const AuthState.signUpSuccess());
      },
    );
  }

  Future<void> _onForgotPassword(String email, Emitter<AuthState> emit) async {
    emit(const AuthState.forgotPasswordLoading());
    final result = await _authRepository.sendPasswordResetOtp(email: email);

    result.when(
      data: (_) {
        emit(AuthState.otpSent(email: email));
      },
      error: (error) {
        emit(
          AuthState.forgotPasswordError(
            error.message ?? 'Failed to send reset code. Please check your email.',
          ),
        );
      },
    );
  }

  Future<void> _onVerifyOtp(
    String email,
    String otp,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.verifyOtpLoading());
    final result = await _authRepository.verifyOtp(email: email, otp: otp);

    result.when(
      data: (_) {
        emit(AuthState.otpVerified(email: email));
      },
      error: (error) {
        emit(
          AuthState.verifyOtpError(
            error.message ?? 'Verification failed. Please check the code.',
          ),
        );
      },
    );
  }

  Future<void> _onResetPassword(
    String email,
    String newPassword,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.resetPasswordLoading());
    final result = await _authRepository.resetPassword(
      email: email,
      newPassword: newPassword,
    );

    result.when(
      data: (_) => emit(const AuthState.passwordResetSuccess()),
      error: (error) {
        emit(
          AuthState.resetPasswordError(
            error.message ?? 'Failed to reset password. Please try again.',
          ),
        );
      },
    );
  }

  Future<void> _onLogout(Emitter<AuthState> emit) async {
    await _authRepository.logout();
    await _logoutUseCase();
    _authStatus.setUnauthenticated();
    emit(const AuthState.initial());
  }
}
