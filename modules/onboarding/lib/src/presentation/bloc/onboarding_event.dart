import 'package:shared/shared.dart';

abstract class OnboardingEvent {
  const OnboardingEvent();

  static OnboardingEvent saveRiderOnboarding({
    required String phoneNumber,
    required String registrationNumber,
    Company? company,
  }) => SaveRiderOnboarding(phoneNumber: phoneNumber, registrationNumber: registrationNumber, company: company);

  static OnboardingEvent saveDispatcherOnboarding({
    String? companyName,
    String? phoneNumber,
    String? address,
    String? cac,
  }) => SaveDispatcherOnboarding(companyName: companyName, phoneNumber: phoneNumber, address: address, cac: cac);

  static OnboardingEvent saveCustomerOnboarding() => const SaveCustomerOnboarding();
  static OnboardingEvent submitOnboarding() => const SubmitOnboarding();

  T map<T>({
    required T Function(SaveRiderOnboarding) saveRiderOnboarding,
    required T Function(SaveDispatcherOnboarding) saveDispatcherOnboarding,
    required T Function(SaveCustomerOnboarding) saveCustomerOnboarding,
    required T Function(SubmitOnboarding) submitOnboarding,
  });
}

class SaveRiderOnboarding extends OnboardingEvent {
  const SaveRiderOnboarding({required this.phoneNumber, required this.registrationNumber, this.company});
  final String phoneNumber;
  final String registrationNumber;
  final Company? company;
  
  @override
  T map<T>({
    required T Function(SaveRiderOnboarding) saveRiderOnboarding,
    required T Function(SaveDispatcherOnboarding) saveDispatcherOnboarding,
    required T Function(SaveCustomerOnboarding) saveCustomerOnboarding,
    required T Function(SubmitOnboarding) submitOnboarding,
  }) => saveRiderOnboarding(this);
}

class SaveDispatcherOnboarding extends OnboardingEvent {
  const SaveDispatcherOnboarding({this.companyName, this.phoneNumber, this.address, this.cac});
  final String? companyName;
  final String? phoneNumber;
  final String? address;
  final String? cac;
  
  @override
  T map<T>({
    required T Function(SaveRiderOnboarding) saveRiderOnboarding,
    required T Function(SaveDispatcherOnboarding) saveDispatcherOnboarding,
    required T Function(SaveCustomerOnboarding) saveCustomerOnboarding,
    required T Function(SubmitOnboarding) submitOnboarding,
  }) => saveDispatcherOnboarding(this);
}

class SaveCustomerOnboarding extends OnboardingEvent {
  const SaveCustomerOnboarding();
  @override
  T map<T>({
    required T Function(SaveRiderOnboarding) saveRiderOnboarding,
    required T Function(SaveDispatcherOnboarding) saveDispatcherOnboarding,
    required T Function(SaveCustomerOnboarding) saveCustomerOnboarding,
    required T Function(SubmitOnboarding) submitOnboarding,
  }) => saveCustomerOnboarding(this);
}

class SubmitOnboarding extends OnboardingEvent {
  const SubmitOnboarding();
  @override
  T map<T>({
    required T Function(SaveRiderOnboarding) saveRiderOnboarding,
    required T Function(SaveDispatcherOnboarding) saveDispatcherOnboarding,
    required T Function(SaveCustomerOnboarding) saveCustomerOnboarding,
    required T Function(SubmitOnboarding) submitOnboarding,
  }) => submitOnboarding(this);
}
