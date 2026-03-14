import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shared/shared.dart';

part 'onboarding_event.freezed.dart';

@freezed
class OnboardingEvent with _$OnboardingEvent {
  const factory OnboardingEvent.submitRiderOnboarding({
    required String phoneNumber,
    required String registrationNumber,
  }) = _SubmitRiderOnboarding;

  const factory OnboardingEvent.updateProgress({
    Company? company,
    // bool? isIndependent,
    // String? permitUrl,
  }) = _UpdateProgress;

  const factory OnboardingEvent.submitDispatcherOnboarding({
    required String companyName,
    required String phoneNumber,
    required String address,
    required String cac,
  }) = _SubmitDispatcherOnboarding;

  const factory OnboardingEvent.backToAuth() = _BackToAuth;
}
