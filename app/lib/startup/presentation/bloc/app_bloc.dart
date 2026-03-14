import 'package:bootstrap/definitions/app_error.dart';
import 'package:bootstrap/definitions/result.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logistix/startup/domain/repositories/startup_repository.dart';
import 'package:logistix/startup/presentation/bloc/app_event.dart';
import 'package:logistix/startup/presentation/bloc/app_state.dart';
import 'package:shared/shared.dart' hide AppEvent;

class AppBloc extends Bloc<AppEvent, AppState> {
  AppBloc(this.startupRepo) : super(const AppState.initializing()) {
    on<AppEvent>((event, emit) async {
      await event.when(initialize: () => _onInitialize(emit));
    });
  }

  final StartupRepository startupRepo;

  Future<void> _onInitialize(Emitter<AppState> emit) async {
    // Show initializing state (splash screen)
    emit(const AppState.initializing());

    // Run user fetch and delay in parallel for efficiency
    final results = await Future.wait<dynamic>([
      startupRepo.getCurrentUser(),
      Future<void>.delayed(const Duration(milliseconds: 1500)),
    ]);

    (results[0]! as Result<AppError, User?>).map(
      (_) {
        // If there's an error checking auth, treat as unauthenticated
        emit(const AppState.unauthenticated());
      },
      (user) {
        if (user == null) {
          // No user logged in
          emit(const AppState.unauthenticated());
        } else if (!user.isOnboarded || user.role == null) {
          // User exists but not onboarded
          emit(AppState.needsOnboarding(user: user));
        } else {
          // User is fully authenticated and onboarded
          emit(AppState.authenticated(user: user, role: user.role!));
        }
      },
    );
  }
}
