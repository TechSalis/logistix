import 'package:shared/shared.dart';

abstract class AppEvent {
  const AppEvent();

  const factory AppEvent.initialize() = _Initialize;
  const factory AppEvent.sessionStatusChanged(AuthSession session) = _SessionStatusChanged;

  T when<T>({
    required T Function() initialize,
    required T Function(AuthSession session) sessionStatusChanged,
  }) {
    if (this is _Initialize) {
      return initialize();
    } else if (this is _SessionStatusChanged) {
      return sessionStatusChanged((this as _SessionStatusChanged).session);
    }
    throw UnimplementedError();
  }
}

class _Initialize extends AppEvent {
  const _Initialize();
}

class _SessionStatusChanged extends AppEvent {
  const _SessionStatusChanged(this.session);
  final AuthSession session;
}
