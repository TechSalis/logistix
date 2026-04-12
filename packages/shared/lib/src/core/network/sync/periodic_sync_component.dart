import 'dart:async';
import 'package:shared/shared.dart';

/// Triggers a periodic synchronization event across the session.
class PeriodicSyncComponent extends SessionComponent {
  PeriodicSyncComponent({
    required this.interval,
    this.initialDelay = const Duration(seconds: 5),
  });

  final Duration interval;
  final Duration initialDelay;
  Timer? _timer;

  @override
  String get id => 'periodic_sync';

  @override
  Future<void> start() async {
    // Initial delay to avoid startup congestion
    _timer = Timer(initialDelay, _startPeriodicTimer);
  }

  void _startPeriodicTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(interval, (_) => sync());
  }

  @override
  Future<void> stop() async {
    _timer?.cancel();
    _timer = null;
  }
}
