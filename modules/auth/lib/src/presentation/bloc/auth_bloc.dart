import 'dart:async';

import 'package:auth/src/domain/repositories/auth_repository.dart';
import 'package:auth/src/presentation/bloc/auth_event.dart';
import 'package:auth/src/presentation/bloc/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared/shared.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this._authRepository, this._userStore, this._logoutUseCase)
    : super(const AuthState.initial()) {
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

  Future<void> _onLogin(
    String email,
    String password,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());

    final result = await _authRepository.login(email, password);
    await result.map<FutureOr<void>>(
      (error) => emit(AuthState.unauthenticated(message: error.message)),
      (user) async {
        await _userStore.saveUser(user);

        // Check if user needs onboarding
        if (user.isOnboarded) {
          emit(AuthState.authenticated(user: user));
        } else {
          emit(AuthState.pendingOnboarding(user: user));
        }
      },
    );
  }

  Future<void> _onSignUp(
    String email,
    String password,
    String name,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());

    final result = await _authRepository.signUp(
      email: email,
      password: password,
      name: name,
    );

    await result.map(
      (error) {
        emit(AuthState.unauthenticated(message: error.message));
      },
      (user) async {
        await _userStore.saveUser(user);
        // New users are not onboarded, need to go through onboarding flow
        emit(AuthState.pendingOnboarding(user: user));
      },
    );
  }

  Future<void> _onForgotPassword(String email, Emitter<AuthState> emit) async {
    emit(const AuthState.loading());

    final result = await _authRepository.sendPasswordResetOtp(email: email);

    result.when(
      data: (_) {
        emit(AuthState.otpSent(email: email));
      },
      error: (error) {
        emit(AuthState.unauthenticated(message: error.message));
      },
    );
  }

  Future<void> _onVerifyOtp(
    String email,
    String otp,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());

    final result = await _authRepository.verifyOtp(email: email, otp: otp);

    result.when(
      data: (_) {
        emit(AuthState.otpVerified(email: email));
      },
      error: (error) {
        emit(AuthState.unauthenticated(message: error.message));
      },
    );
  }

  Future<void> _onResetPassword(
    String email,
    String newPassword,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());

    final result = await _authRepository.resetPassword(
      email: email,
      newPassword: newPassword,
    );

    result.when(
      data: (_) {
        emit(const AuthState.passwordResetSuccess());
      },
      error: (error) {
        emit(AuthState.unauthenticated(message: error.message));
      },
    );
  }

  Future<void> _onLogout(Emitter<AuthState> emit) async {
    await _authRepository.logout();
    await _logoutUseCase();
    emit(const AuthState.unauthenticated());
  }
}
