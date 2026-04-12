import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onboarding/src/data/models/dispatcher_profile_dto.dart';
import 'package:onboarding/src/data/models/rider_profile_dto.dart';
import 'package:onboarding/src/domain/repositories/onboarding_repository.dart';
import 'package:onboarding/src/presentation/bloc/onboarding_event.dart';
import 'package:onboarding/src/presentation/bloc/onboarding_state.dart';
import 'package:shared/shared.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  OnboardingBloc(this._repository, this._authStatusRepository)
    : super(OnboardingState.initial()) {
    on<OnboardingEvent>((event, emit) async {
      await event.map<FutureOr<void>>(
        saveRiderOnboarding: (e) => _onSaveRiderOnboarding(e, emit),
        saveDispatcherOnboarding: (e) => _onSaveDispatcherOnboarding(e, emit),
        saveCustomerOnboarding: (e) => emit(OnboardingState.customer()),
        submitOnboarding: (e) => _onSubmitOnboarding(emit),
      );
    });
  }

  final OnboardingRepository _repository;
  final AuthStatusRepository _authStatusRepository;

  void backToAuth() => _authStatusRepository.setUnauthenticated();

  Future<void> _onSaveRiderOnboarding(
    SaveRiderOnboarding event,
    Emitter<OnboardingState> emit,
  ) async {
    emit(
      OnboardingState.rider(
        phoneNumber: event.phoneNumber,
        registrationNumber: event.registrationNumber,
        company: event.company,
      ),
    );
  }

  Future<void> _onSaveDispatcherOnboarding(
    SaveDispatcherOnboarding event,
    Emitter<OnboardingState> emit,
  ) async {
    emit(
      OnboardingState.dispatcher(
        companyName: event.companyName,
        phoneNumber: event.phoneNumber,
        address: event.address,
        cac: event.cac,
      ),
    );
  }

  Future<void> _onSubmitOnboarding(Emitter<OnboardingState> emit) async {
    await state.maybeMap<FutureOr<void>>(
      rider: (state) async {
        emit(state.copyWith(status: OnboardingStatus.loading));
        final profile = RiderProfileDto(
          phoneNumber: state.phoneNumber,
          registrationNumber: state.registrationNumber,
          companyId: state.company?.id,
        );

        final result = await _repository.submitRiderProfile(profile);

        result.map(
          (error) => emit(
            state.copyWith(
              status: OnboardingStatus.error,
              message: error.message,
            ),
          ),
          (user) {
            _authStatusRepository.setAuthenticated(user);
            emit(state.copyWith(status: OnboardingStatus.success));
          },
        );
      },
      dispatcher: (state) async {
        emit(state.copyWith(status: OnboardingStatus.loading));
        final profile = DispatcherProfileDto(
          companyName: state.companyName,
          phoneNumber: state.phoneNumber,
          address: state.address,
          cac: state.cac,
        );

        final result = await _repository.submitDispatcherProfile(profile);

        result.map(
          (error) => emit(
            state.copyWith(
              status: OnboardingStatus.error,
              message: error.message,
            ),
          ),
          (user) {
            _authStatusRepository.setAuthenticated(user);
            emit(state.copyWith(status: OnboardingStatus.success));
          },
        );
      },
      customer: (state) async {
        emit(state.copyWith(status: OnboardingStatus.loading));
        final result = await _repository.submitCustomerProfile();

        result.map(
          (error) => emit(
            state.copyWith(
              status: OnboardingStatus.error,
              message: error.message,
            ),
          ),
          (user) {
            _authStatusRepository.setAuthenticated(user);
            emit(state.copyWith(status: OnboardingStatus.success));
          },
        );
      },
      orElse: () {},
    );
  }
}
