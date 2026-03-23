import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shared/shared.dart';

part 'app_state.freezed.dart';

@freezed
class AppState with _$AppState {
  const factory AppState.initializing() = _Initializing;
  const factory AppState.unauthenticated() = _Unauthenticated;
  const factory AppState.needsOnboarding({required User user}) =
      _NeedsOnboarding;
  const factory AppState.authenticated({
    required User user,
    required UserRole role,
  }) = _Authenticated;
  const factory AppState.error(String message) = _Error;

  const AppState._();

  bool get isInitializing => this is _Initializing;
}
