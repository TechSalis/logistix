import 'package:shared/shared.dart';

/// A generic component that manages a domain-specific real-time subscription.
class RealtimeSubscriptionComponent extends SessionComponent {
  RealtimeSubscriptionComponent({
    required this.name,
    required this.subscribe,
  });

  final String name;
  final Future<SyncManager> Function(Future<void> Function() onSync) subscribe;
  SyncManager? _manager;

  @override
  String get id => 'subscription_$name';

  @override
  Future<void> start() async {
    _manager = await subscribe(sync);
  }

  @override
  Future<void> stop() async {
    _manager?.stop();
    _manager = null;
  }
}
