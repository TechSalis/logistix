import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shared/shared.dart';

part 'app_event.freezed.dart';

@freezed
class AppEvent with _$AppEvent {
  const factory AppEvent.initialize() = _Initialize;
  const factory AppEvent.sessionStatusChanged(AuthSession session) =
      _SessionStatusChanged;
}
