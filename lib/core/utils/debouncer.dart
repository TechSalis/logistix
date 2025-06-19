import 'dart:async';

class Debouncer {
  Timer? _debounceTimer;

  void debounce({required Duration duration, required Function() onDebounce}) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(duration, onDebounce);
  }

  void cancel() => _debounceTimer?.cancel();
}
