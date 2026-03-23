import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shared/shared.dart';

part 'onboarding_state.freezed.dart';

enum OnboardingStatus { initial, loading, success, error }

@freezed
class OnboardingState with _$OnboardingState {
  const OnboardingState._();

  const factory OnboardingState.rider({
    required String phoneNumber,
    required String registrationNumber,
    required Company company,
    @Default(OnboardingStatus.initial) OnboardingStatus status,
    String? message,
  }) = _RiderOnboardingState;

  const factory OnboardingState.dispatcher({
    required String companyName,
    required String phoneNumber,
    required String address,
    required String cac,
    @Default(OnboardingStatus.initial) OnboardingStatus status,
    String? message,
  }) = _DispatcherOnboardingState;

  const factory OnboardingState.customer({
    @Default(OnboardingStatus.initial) OnboardingStatus status,
    String? message,
  }) = _CustomerOnboardingState;

  const factory OnboardingState.initial() = _Initial;

  OnboardingStatus get status => maybeMap(
    dispatcher: (state) => state.status,
    customer: (state) => state.status,
    rider: (state) => state.status,
    orElse: () => OnboardingStatus.initial,
  );

  String? get message => maybeMap(
    dispatcher: (state) => state.message,
    customer: (state) => state.message,
    rider: (state) => state.message,
    orElse: () => null,
  );
}
