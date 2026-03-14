import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shared/shared.dart';

part 'onboarding_state.freezed.dart';

enum OnboardingStatus { initial, loading, success, error }

@freezed
class OnboardingState with _$OnboardingState {
  const factory OnboardingState({
    @Default(OnboardingStatus.initial) OnboardingStatus status,
    String? message,
    Company? company,
    // @Default(false) bool isIndependent,
    // String? permitUrl,
  }) = _OnboardingState;

  factory OnboardingState.initial() => const OnboardingState();
}
