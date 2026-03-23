import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shared/shared.dart';

part 'onboarding_event.freezed.dart';

@freezed
class OnboardingEvent with _$OnboardingEvent {
  const factory OnboardingEvent.saveRiderOnboarding({
    required String phoneNumber,
    required String registrationNumber,
    required Company company,
  }) = _SaveRiderOnboarding;

  const factory OnboardingEvent.saveDispatcherOnboarding({
    required String companyName,
    required String phoneNumber,
    required String address,
    required String cac,
  }) = _SaveDispatcherOnboarding;

  const factory OnboardingEvent.saveCustomerOnboarding() =
      _SaveCustomerOnboarding;

  const factory OnboardingEvent.submitOnboarding() = _SubmitOnboarding;
}
