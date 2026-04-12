import 'dart:async';
import 'package:shared/shared.dart';

/// Reusable component for initializing push notifications and registering FCM tokens.
class NotificationComponent extends SessionComponent {
  NotificationComponent({required this.initializeNotifications});

  final InitializeNotificationsUseCase initializeNotifications;
  StreamSubscription<void>? _subscription;

  @override
  String get id => 'notifications';

  @override
  Future<void> start() async {
    final result = await initializeNotifications();
    
    // Process result using bootstrap's Result pattern
    result.when(
      data: (sub) => _subscription = sub,
    );
  }

  @override
  Future<void> stop() async {
    await _subscription?.cancel();
    _subscription = null;
  }
}
