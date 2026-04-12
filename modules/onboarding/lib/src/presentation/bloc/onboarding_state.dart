import 'package:shared/shared.dart';

enum OnboardingStatus { initial, loading, success, error }

abstract class OnboardingState {
  const OnboardingState();

  static OnboardingState initial() => const OnboardingInitial();
  static OnboardingState rider({
    required String phoneNumber,
    required String registrationNumber,
    Company? company,
    OnboardingStatus status = OnboardingStatus.initial,
    String? message,
  }) => RiderOnboardingState(
        phoneNumber: phoneNumber,
        registrationNumber: registrationNumber,
        company: company,
        status: status,
        message: message,
      );

  static OnboardingState dispatcher({
    String? companyName,
    String? phoneNumber,
    String? address,
    String? cac,
    OnboardingStatus status = OnboardingStatus.initial,
    String? message,
  }) => DispatcherOnboardingState(
        companyName: companyName,
        phoneNumber: phoneNumber,
        address: address,
        cac: cac,
        status: status,
        message: message,
      );

  static OnboardingState customer({
    OnboardingStatus status = OnboardingStatus.initial,
    String? message,
  }) => CustomerOnboardingState(status: status, message: message);

  OnboardingStatus get status;
  String? get message;

  T when<T>({
    required T Function() initial,
    required T Function(String phoneNumber, String registrationNumber, Company? company, OnboardingStatus status, String? message) rider,
    required T Function(String? companyName, String? phoneNumber, String? address, String? cac, OnboardingStatus status, String? message) dispatcher,
    required T Function(OnboardingStatus status, String? message) customer,
  });

  T? mapOrNull<T>({
    T? Function(OnboardingInitial)? initial,
    T? Function(RiderOnboardingState)? rider,
    T? Function(DispatcherOnboardingState)? dispatcher,
    T? Function(CustomerOnboardingState)? customer,
  });

  T maybeMap<T>({
    required T Function() orElse, T Function(OnboardingInitial)? initial,
    T Function(RiderOnboardingState)? rider,
    T Function(DispatcherOnboardingState)? dispatcher,
    T Function(CustomerOnboardingState)? customer,
  });
}

class OnboardingInitial extends OnboardingState {
  const OnboardingInitial();
  @override
  OnboardingStatus get status => OnboardingStatus.initial;
  @override
  String? get message => null;

  @override
  T when<T>({required T Function() initial, required T Function(String phoneNumber, String registrationNumber, Company? company, OnboardingStatus status, String? message) rider, required T Function(String? companyName, String? phoneNumber, String? address, String? cac, OnboardingStatus status, String? message) dispatcher, required T Function(OnboardingStatus status, String? message) customer}) => initial();

  @override
  T? mapOrNull<T>({T? Function(OnboardingInitial)? initial, T? Function(RiderOnboardingState)? rider, T? Function(DispatcherOnboardingState)? dispatcher, T? Function(CustomerOnboardingState)? customer}) => initial?.call(this);

  @override
  T maybeMap<T>({required T Function() orElse, T Function(OnboardingInitial)? initial, T Function(RiderOnboardingState)? rider, T Function(DispatcherOnboardingState)? dispatcher, T Function(CustomerOnboardingState)? customer}) => initial != null ? initial(this) : orElse();
}

class RiderOnboardingState extends OnboardingState {

  const RiderOnboardingState({required this.phoneNumber, required this.registrationNumber, this.company, this.status = OnboardingStatus.initial, this.message});
  final String phoneNumber;
  final String registrationNumber;
  final Company? company;
  @override
  final OnboardingStatus status;
  @override
  final String? message;

  @override
  T when<T>({required T Function() initial, required T Function(String phoneNumber, String registrationNumber, Company? company, OnboardingStatus status, String? message) rider, required T Function(String? companyName, String? phoneNumber, String? address, String? cac, OnboardingStatus status, String? message) dispatcher, required T Function(OnboardingStatus status, String? message) customer}) => rider(phoneNumber, registrationNumber, company, status, message);

  @override
  T? mapOrNull<T>({T? Function(OnboardingInitial)? initial, T? Function(RiderOnboardingState)? rider, T? Function(DispatcherOnboardingState)? dispatcher, T? Function(CustomerOnboardingState)? customer}) => rider?.call(this);

  @override
  T maybeMap<T>({required T Function() orElse, T Function(OnboardingInitial)? initial, T Function(RiderOnboardingState)? rider, T Function(DispatcherOnboardingState)? dispatcher, T Function(CustomerOnboardingState)? customer}) => rider != null ? rider(this) : orElse();

  RiderOnboardingState copyWith({String? phoneNumber, String? registrationNumber, Company? company, OnboardingStatus? status, String? message}) {
    return RiderOnboardingState(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      company: company ?? this.company,
      status: status ?? this.status,
      message: message ?? this.message,
    );
  }
}

class DispatcherOnboardingState extends OnboardingState {

  const DispatcherOnboardingState({this.companyName, this.phoneNumber, this.address, this.cac, this.status = OnboardingStatus.initial, this.message});
  final String? companyName;
  final String? phoneNumber;
  final String? address;
  final String? cac;
  @override
  final OnboardingStatus status;
  @override
  final String? message;

  @override
  T when<T>({required T Function() initial, required T Function(String phoneNumber, String registrationNumber, Company? company, OnboardingStatus status, String? message) rider, required T Function(String? companyName, String? phoneNumber, String? address, String? cac, OnboardingStatus status, String? message) dispatcher, required T Function(OnboardingStatus status, String? message) customer}) => dispatcher(companyName, phoneNumber, address, cac, status, message);

  @override
  T? mapOrNull<T>({T? Function(OnboardingInitial)? initial, T? Function(RiderOnboardingState)? rider, T? Function(DispatcherOnboardingState)? dispatcher, T? Function(CustomerOnboardingState)? customer}) => dispatcher?.call(this);

  @override
  T maybeMap<T>({required T Function() orElse, T Function(OnboardingInitial)? initial, T Function(RiderOnboardingState)? rider, T Function(DispatcherOnboardingState)? dispatcher, T Function(CustomerOnboardingState)? customer}) => dispatcher != null ? dispatcher(this) : orElse();

  DispatcherOnboardingState copyWith({String? companyName, String? phoneNumber, String? address, String? cac, OnboardingStatus? status, String? message}) {
    return DispatcherOnboardingState(
      companyName: companyName ?? this.companyName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      cac: cac ?? this.cac,
      status: status ?? this.status,
      message: message ?? this.message,
    );
  }
}

class CustomerOnboardingState extends OnboardingState {

  const CustomerOnboardingState({this.status = OnboardingStatus.initial, this.message});
  @override
  final OnboardingStatus status;
  @override
  final String? message;

  @override
  T when<T>({required T Function() initial, required T Function(String phoneNumber, String registrationNumber, Company? company, OnboardingStatus status, String? message) rider, required T Function(String? companyName, String? phoneNumber, String? address, String? cac, OnboardingStatus status, String? message) dispatcher, required T Function(OnboardingStatus status, String? message) customer}) => customer(status, message);

  @override
  T? mapOrNull<T>({T? Function(OnboardingInitial)? initial, T? Function(RiderOnboardingState)? rider, T? Function(DispatcherOnboardingState)? dispatcher, T? Function(CustomerOnboardingState)? customer}) => customer?.call(this);

  @override
  T maybeMap<T>({required T Function() orElse, T Function(OnboardingInitial)? initial, T Function(RiderOnboardingState)? rider, T Function(DispatcherOnboardingState)? dispatcher, T Function(CustomerOnboardingState)? customer}) => customer != null ? customer(this) : orElse();

  CustomerOnboardingState copyWith({OnboardingStatus? status, String? message}) {
    return CustomerOnboardingState(
      status: status ?? this.status,
      message: message ?? this.message,
    );
  }
}
