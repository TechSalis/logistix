import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logistix/startup/presentation/bloc/app_event.dart';
import 'package:logistix/startup/presentation/bloc/app_state.dart';
import 'package:shared/shared.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  AppBloc(
    this.appRepo,
    this._clearAppDataUseCase,
    this._authStatusRepository,
    this._initNotificationsUseCase,
  ) : super(const AppState.initializing()) {
    _authSubscription = _authStatusRepository.session.listen((session) {
      add(AppEvent.sessionStatusChanged(session));
    });

    on<AppEvent>((event, emit) async {
      await event.when(
        initialize: () => _onInitialize(emit),
        sessionStatusChanged: (session) => _onStatusChanged(session, emit),
      );
    });
  }

  final ClearAppDataUseCase _clearAppDataUseCase;
  final AppRepository appRepo;
  final AuthStatusRepository _authStatusRepository;
  final InitializeNotificationsUseCase _initNotificationsUseCase;

  late final StreamSubscription<AuthSession> _authSubscription;
  StreamSubscription<void>? _notificationSubscription;

  @override
  Future<void> close() {
    _authSubscription.cancel();
    _notificationSubscription?.cancel();
    return super.close();
  }

  Future<void> _startNotifications() async {
    await _notificationSubscription?.cancel();
    final result = await _initNotificationsUseCase();
    result.when(data: (sub) => _notificationSubscription = sub);
  }

  void _stopNotifications() {
    _notificationSubscription?.cancel();
    _notificationSubscription = null;
  }

  Future<void> _onInitialize(Emitter<AppState> emit) async {
    if (!state.isInitializing) emit(const AppState.initializing());

    final result = await appRepo.getCurrentUser();

    result.map(
      (error) => emit(
        AppState.error(
          error.message ??
              'An unexpected error occurred while starting the app',
        ),
      ),
      (user) {
        if (user == null) {
          _authStatusRepository.setUnauthenticated();
        } else {
          _authStatusRepository.setAuthenticated(user);
        }
      },
    );
  }

  Future<void> _onStatusChanged(
    AuthSession session,
    Emitter<AppState> emit,
  ) async {
    switch (session.status) {
      case AuthStatus.unauthenticated:
        _stopNotifications();
        await _clearAppDataUseCase();
        emit(const AppState.unauthenticated());
      case AuthStatus.authenticated:
        if (session.user?.role != null) {
          emit(
            AppState.authenticated(
              user: session.user!,
              role: session.user!.role!,
            ),
          );
          await _startNotifications();
        }
      case AuthStatus.onboarding:
        if (session.user != null) {
          emit(AppState.needsOnboarding(user: session.user!));
        }
      case AuthStatus.unknown:
        if (!state.isInitializing) {
          emit(const AppState.initializing());
        }
    }
  }
}
