import 'dart:async';

import 'package:bootstrap/definitions/app_error.dart';
import 'package:bootstrap/services/async_runner/async_runner.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onboarding/src/data/models/dispatcher_profile_dto.dart';
import 'package:onboarding/src/data/models/rider_profile_dto.dart';
import 'package:onboarding/src/domain/repositories/onboarding_repository.dart';
import 'package:onboarding/src/presentation/bloc/onboarding_event.dart';
import 'package:onboarding/src/presentation/bloc/onboarding_state.dart';
import 'package:shared/shared.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  OnboardingBloc(this._repository, this._logoutUseCase)
    : super(OnboardingState.initial()) {
    on<OnboardingEvent>((event, emit) async {
      await event.when<FutureOr<void>>(
        updateProgress: (company) => _onUpdateProgress(company, emit),
        submitRiderOnboarding: (phoneNumber, registrationNumber) {
          return _onSubmitRiderOnboarding(
            phoneNumber,
            registrationNumber,
            emit,
          );
        },
        submitDispatcherOnboarding: (companyName, phoneNumber, address, cac) {
          return _onSubmitDispatcherOnboarding(
            companyName,
            phoneNumber,
            address,
            cac,
            emit,
          );
        },
        backToAuth: () => _onBackToAuth(emit),
      );
    });
  }

  final OnboardingRepository _repository;
  final LogoutUseCase _logoutUseCase;

  late final backToAuthRunner = AsyncRunner<AppError, void>(
    _logoutUseCase.call,
  );

  void _onUpdateProgress(
    Company? company,
    // bool? isIndependent,
    // String? permitUrl,
    Emitter<OnboardingState> emit,
  ) {
    emit(
      state.copyWith(
        company: company ?? state.company,
        // isIndependent: isIndependent ?? state.isIndependent,
        // permitUrl: permitUrl ?? state.permitUrl,
      ),
    );
  }

  Future<void> _onBackToAuth(Emitter<OnboardingState> emit) async {
    await _logoutUseCase();
    emit(OnboardingState.initial());
  }

  Future<void> _onSubmitRiderOnboarding(
    String phoneNumber,
    String registrationNumber,
    Emitter<OnboardingState> emit,
  ) async {
    emit(state.copyWith(status: OnboardingStatus.loading));

    final profile = RiderProfileDto(
      phoneNumber: phoneNumber,
      registrationNumber: registrationNumber,
      companyId: state.company?.id,
      // isIndependent: state.isIndependent,
      // permitUrl: state.permitUrl,
    );

    final result = await _repository.submitRiderProfile(profile);

    result.map(
      (error) => emit(
        state.copyWith(status: OnboardingStatus.error, message: error.message),
      ),
      (_) => emit(state.copyWith(status: OnboardingStatus.success)),
    );
  }

  Future<void> _onSubmitDispatcherOnboarding(
    String companyName,
    String phoneNumber,
    String address,
    String cac,
    Emitter<OnboardingState> emit,
  ) async {
    emit(state.copyWith(status: OnboardingStatus.loading));

    final profile = DispatcherProfileDto(
      companyName: companyName,
      phoneNumber: phoneNumber,
      address: address,
      cac: cac,
    );

    final result = await _repository.submitDispatcherProfile(profile);

    result.when(
      data: (_) => emit(state.copyWith(status: OnboardingStatus.success)),
      error: (error) => emit(
        state.copyWith(status: OnboardingStatus.error, message: error.message),
      ),
    );
  }
}
