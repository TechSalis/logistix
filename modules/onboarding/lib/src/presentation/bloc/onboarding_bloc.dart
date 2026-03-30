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
    : super(const OnboardingState.initial()) {
    on<OnboardingEvent>((event, emit) async {
      await event.when<FutureOr<void>>(
        saveRiderOnboarding: (phoneNumber, registrationNumber, company) {
          return _onSaveRiderOnboarding(
            phoneNumber,
            registrationNumber,
            company,
            emit,
          );
        },
        saveDispatcherOnboarding: (companyName, phoneNumber, address, cac) {
          return _onSaveDispatcherOnboarding(
            companyName,
            phoneNumber,
            address,
            cac,
            emit,
          );
        },
        saveCustomerOnboarding: () => emit(const OnboardingState.customer()),
        submitOnboarding: () => _onSubmitOnboarding(emit),
      );
    });
  }

  final OnboardingRepository _repository;
  final AuthStatusRepository _authStatusRepository;

  void backToAuth() => _authStatusRepository.setUnauthenticated();

  Future<void> _onSaveRiderOnboarding(
    String phoneNumber,
    String registrationNumber,
    Company company,
    Emitter<OnboardingState> emit,
  ) async {
    emit(
      OnboardingState.rider(
        phoneNumber: phoneNumber,
        registrationNumber: registrationNumber,
        company: company,
      ),
    );
  }

  Future<void> _onSaveDispatcherOnboarding(
    String companyName,
    String phoneNumber,
    String address,
    String cac,
    Emitter<OnboardingState> emit,
  ) async {
    emit(
      OnboardingState.dispatcher(
        companyName: companyName,
        phoneNumber: phoneNumber,
        address: address,
        cac: cac,
      ),
    );
  }

  Future<void> _onSubmitOnboarding(Emitter<OnboardingState> emit) async {
    await state.map<FutureOr<void>>(
      initial: (value) {},
      rider: (state) async {
        final profile = RiderProfileDto(
          phoneNumber: state.phoneNumber,
          registrationNumber: state.registrationNumber,
          companyId: state.company.id,
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
        final profile = DispatcherProfileDto(
          companyName: state.companyName,
          phoneNumber: state.phoneNumber,
          address: state.address,
          cac: state.cac,
        );

        final result = await _repository.submitDispatcherProfile(profile);

        result.when(
          data: (user) {
            _authStatusRepository.setAuthenticated(user);
            emit(state.copyWith(status: OnboardingStatus.success));
          },
          error: (error) => emit(
            state.copyWith(
              status: OnboardingStatus.error,
              message: error.message,
            ),
          ),
        );
      },
      customer: (state) async {
        final result = await _repository.submitCustomerProfile();

        result.when(
          data: (user) {
            _authStatusRepository.setAuthenticated(user);
            emit(state.copyWith(status: OnboardingStatus.success));
          },
          error: (error) => emit(
            state.copyWith(
              status: OnboardingStatus.error,
              message: error.message,
            ),
          ),
        );
      },
    );
  }
}
