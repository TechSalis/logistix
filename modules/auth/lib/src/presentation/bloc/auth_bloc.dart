import 'dart:async';

import 'package:auth/src/presentation/bloc/auth_event.dart';
import 'package:auth/src/presentation/bloc/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared/shared.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(
    this._authRepository,
    this._userStore,
    AuthStatusRepository authStatus,
  ) : _authStatus = authStatus,
      super(const AuthInitial()) {
    on<AuthLogin>((event, emit) => _onLogin(event.email, event.password, emit));
    on<AuthSignUp>(
      (event, emit) => _onSignUp(event.email, event.password, event.name, emit),
    );
    on<AuthForgotPassword>(
      (event, emit) => _onForgotPassword(event.email, emit),
    );
    on<AuthVerifyOtp>(
      (event, emit) => _onVerifyOtp(event.email, event.otp, emit),
    );
    on<AuthResetPassword>(
      (event, emit) => _onResetPassword(event.email, event.newPassword, emit),
    );
    on<AuthLogout>((event, emit) => _onLogout(emit));
  }

  final AuthRepository _authRepository;
  final UserStore _userStore;
  final AuthStatusRepository _authStatus;

  Future<void> _onLogin(
    String email,
    String password,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoginLoading());
    final result = await _authRepository.login(email, password);

    result.map<FutureOr<void>>(
      (error) {
        emit(
          AuthLoginError(
            error.message ??
                'Invalid credentials. Please check your email and password.',
          ),
        );
      },
      (user) async {
        await _userStore.saveUser(user);
        _authStatus.setAuthenticated(user);
        emit(const AuthLoginSuccess());
      },
    );
  }

  Future<void> _onSignUp(
    String email,
    String password,
    String name,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthSignUpLoading());
    final result = await _authRepository.signUp(
      email: email,
      password: password,
      name: name,
    );

    result.map<FutureOr<void>>(
      (error) {
        emit(
          AuthSignUpError(
            error.message ?? 'Failed to create account. Please try again.',
          ),
        );
      },
      (user) async {
        await _userStore.saveUser(user);
        _authStatus.setAuthenticated(user);
        emit(const AuthSignUpSuccess());
      },
    );
  }

  Future<void> _onForgotPassword(String email, Emitter<AuthState> emit) async {
    emit(const AuthForgotPasswordLoading());
    final result = await _authRepository.sendPasswordResetOtp(email: email);

    result.when(
      data: (_) {
        emit(AuthOtpSent(email: email));
      },
      error: (error) {
        emit(
          AuthForgotPasswordError(
            error.message ??
                'Failed to send reset code. Please check your email.',
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
    emit(const AuthVerifyOtpLoading());
    final result = await _authRepository.verifyOtp(email: email, otp: otp);

    result.when(
      data: (_) {
        emit(AuthOtpVerified(email: email));
      },
      error: (error) {
        emit(
          AuthVerifyOtpError(
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
    emit(const AuthResetPasswordLoading());
    final result = await _authRepository.resetPassword(
      email: email,
      newPassword: newPassword,
    );

    result.when(
      data: (_) => emit(const AuthPasswordResetSuccess()),
      error: (error) {
        emit(
          AuthResetPasswordError(
            error.message ?? 'Failed to reset password. Please try again.',
          ),
        );
      },
    );
  }

  Future<void> _onLogout(Emitter<AuthState> emit) async {
    _authStatus.setUnauthenticated();
    emit(const AuthInitial());
  }
}
