import 'dart:async';

import 'package:bootstrap/definitions/app_error.dart';
import 'package:bootstrap/services/async_runner/async_runner.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rider/src/domain/repositories/rider_repository.dart';
import 'package:rider/src/presentation/bloc/rider_event.dart';
import 'package:rider/src/presentation/bloc/rider_state.dart';
import 'package:shared/shared.dart';

class RiderBloc extends Bloc<RiderEvent, RiderState> {
  RiderBloc(this._repository, this._authStatusRepository, this._userStore)
    : super(const RiderState.initial()) {
    on<FetchProfile>(_onFetchProfile);
    on<WatchProfile>(_onWatchProfile);
    on<LocationUpdated>(_onLocationUpdated);
    on<UpdateRiderEvent>(_onUpdateRider);
    on<StatusChanged>(_onStatusChanged);
  }

  final UserStore _userStore;
  final RiderRepository _repository;
  final AuthStatusRepository _authStatusRepository;

  StreamSubscription<Rider?>? _profileSubscription;

  Future<void> _onLocationUpdated(
    LocationUpdated event,
    Emitter<RiderState> emit,
  ) async {
    state.mapOrNull(loaded: (s) => emit(s.copyWith(location: event.position)));
  }

  Future<void> _onStatusChanged(
    StatusChanged event,
    Emitter<RiderState> emit,
  ) async {
    state.mapOrNull(
      loaded: (s) {
        // Update rider's status from backend event
        final updatedRider = s.rider.copyWith(status: event.status);
        emit(s.copyWith(rider: updatedRider));
      },
    );
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
        emit(const RiderState.error('Rider profile not found state'));
      }
    }, (rider) => emit(RiderState.loaded(rider)));
  }

  Future<void> _onWatchProfile(
    WatchProfile event,
    Emitter<RiderState> emit,
  ) async {
    unawaited(_profileSubscription?.cancel());
    _profileSubscription = _repository
        .watchRiderProfile(event.riderId)
        .listen(
          (rider) => add(RiderEvent.updateRider(rider)),
          onError: (Object error) {
            emit(
              RiderState.error(
                (error is UserError ? error.message : null) ??
                    'Failed to watch profile',
              ),
            );
          },
        );
  }

  void logout() {
    _authStatusRepository.setUnauthenticated();
  }

  late final supportRunner = AsyncRunner.withArg<String, AppError, void>(
    _launchSupportUrl,
  );

  Future<void> _launchSupportUrl(String url) async {
    await LauncherUtils.launchInBrowser(url);
  }

  FutureOr<void> _onUpdateRider(
    UpdateRiderEvent event,
    Emitter<RiderState> emit,
  ) {
    if (event.rider != null) {
      emit(RiderState.loaded(event.rider!));
    } else {
      emit(const RiderState.error('Failed to fetch rider data'));
    }
  }

  @override
  Future<void> close() {
    _profileSubscription?.cancel();
    return super.close();
  }
}
