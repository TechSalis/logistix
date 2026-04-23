import 'dart:async';
import 'package:bootstrap/definitions/app_error.dart';
import 'package:bootstrap/extensions/result_extensions.dart';
import 'package:bootstrap/services/async_runner/async_runner.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rider/src/domain/repositories/rider_repository.dart';
import 'package:rider/src/presentation/bloc/rider_event.dart';
import 'package:rider/src/presentation/bloc/rider_state.dart';
import 'package:shared/shared.dart';

class RiderBloc extends Bloc<RiderEvent, RiderState> {
  RiderBloc(
    this._repository, 
    this._logoutUseCase, 
    this._deactivateAccountUseCase,
    this._userStore
  ) : super(RiderState.initial) {
    on<RiderEvent>((event, emit) async {
       await event.map(
         fetchProfile: (e) => _onFetchProfile(e, emit),
         observeProfile: (e) => _onObserveProfile(e, emit),
         locationUpdated: (e) => _onLocationUpdated(e, emit),
         statusChanged: (e) => _onStatusChanged(e, emit),
         updateRider: (e) => _onUpdateRider(e, emit),
         deactivateAccount: (e) => deactivateAccountRunner.call(),
       );
    });
  }

  final UserStore _userStore;
  final RiderRepository _repository;
  final LogoutUseCase _logoutUseCase;
  final DeactivateAccountUseCase _deactivateAccountUseCase;

  StreamSubscription<Rider?>? _profileSubscription;

  Future<void> _onLocationUpdated(
    LocationUpdated event,
    Emitter<RiderState> emit,
  ) async {
    final s = state;
    if (s is RiderLoadedState) {
      emit(s.copyWith(location: event.position));
    }
  }

  Future<void> _onStatusChanged(
    StatusChanged event,
    Emitter<RiderState> emit,
  ) async {
    final s = state;
    if (s is RiderLoadedState) {
      final updatedRider = s.rider.copyWith(status: event.status);
      emit(s.copyWith(rider: updatedRider));
    }
  }

  Future<void> _onFetchProfile(
    FetchProfile event,
    Emitter<RiderState> emit,
  ) async {
    final rider = (await _userStore.getUser())?.riderProfile;
    emit(RiderState.loading(rider));

    final result = await _repository.fetchProfile();

    await result.map<FutureOr<void>>((error) async {
      if (rider == null) {
        emit(RiderState.error('Rider profile not found. Please logout and try again.'));
      }
    }, (rider) => emit(RiderState.loaded(rider)));
  }

  Future<void> _onObserveProfile(
    ObserveProfile event,
    Emitter<RiderState> emit,
  ) async {
    unawaited(_profileSubscription?.cancel());

    final riderId = event.riderId;
    if (riderId.isEmpty) {
      emit(RiderState.error('Authentication Error: Invalid Rider Session'));
      return;
    }

    _profileSubscription = _repository
        .watchRiderProfile(riderId)
        .listen(
          (rider) => add(UpdateRiderEvent(rider)),
          onError: (Object error) {
            emit(
              RiderState.error(
                (error is UserError ? error.message : null) ??
                    'Live Connection Lost: Failed to monitor profile updates',
              ),
            );
          },
        );
  }

  late final logoutRunner = AsyncRunner<AppError, void>(() async {
    final result = await _logoutUseCase();
    return result.throwOrReturn();
  });

  late final deactivateAccountRunner = AsyncRunner<AppError, void>(() async {
    final result = await _deactivateAccountUseCase();
    return result.throwOrReturn();
  });

  late final supportRunner = AsyncRunner<AppError, void>(
    _launchSupportUrl,
  );

  Future<void> _launchSupportUrl() {
    return LogistixLauncher.launchInBrowser(EnvConfig.instance.contactSupportUrl);
  }

  FutureOr<void> _onUpdateRider(
    UpdateRiderEvent event,
    Emitter<RiderState> emit,
  ) {
    if (event.rider != null) {
      emit(RiderState.loaded(event.rider!));
    } else {
      emit(RiderState.error('Data Sync Error: Failed to retrieve latest rider profile'));
    }
  }

  @override
  Future<void> close() {
    _profileSubscription?.cancel();
    return super.close();
  }
}
