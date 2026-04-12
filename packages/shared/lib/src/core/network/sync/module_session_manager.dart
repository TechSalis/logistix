import 'dart:async';
import 'package:shared/shared.dart';

/// A self-contained piece of operational logic tied to a session.
/// 
abstract class SessionComponent {
  /// Unique identifier for the component within a coordinator.
  String get id;

  /// Called when the coordinator starts.
  Future<void> onStart(SessionCoordinator context);

  /// Called when the coordinator stops.
  void onStop();

  /// Optional: Called when a global synchronization event is triggered.
  Future<void> onSync() async {}
}

/// Orchestrates multiple [SessionComponent]s as a single unit.
/// 
/// Manages the registration and cleanup of:
/// - Operational Components.
/// - Low-level [SyncManager]s.
/// - Raw [StreamSubscription]s.
/// - Periodic [Timer]s.
class SessionCoordinator {
  final List<SessionComponent> _components = [];
  final List<SyncManager> _syncManagers = [];
  final List<StreamSubscription<dynamic>> _subscriptions = [];
  final List<Timer> _timers = [];

  bool _isActive = false;
  bool get isActive => _isActive;

  /// Starts all registered components.
  Future<void> start() async {
    if (_isActive) return;
    _isActive = true;
    for (final component in _components) {
      await component.onStart(this);
    }
  }

  /// Manually trigger a sync across all components.
  Future<void> sync() async {
    if (!_isActive) return;
    await Future.wait(_components.map((c) => c.onSync()));
  }

  /// Adds a component to the coordinator.
  void addComponent(SessionComponent component) {
    _components.add(component);
  }

  /// Registers a [SyncManager] for automated disposal.
  T registerSyncManager<T extends SyncManager>(T manager) {
    _syncManagers.add(manager);
    return manager;
  }

  /// Registers a [StreamSubscription] for automated cancellation.
  T registerSubscription<T extends StreamSubscription<dynamic>>(T subscription) {
    _subscriptions.add(subscription);
    return subscription;
  }

  /// Registers a [Timer] for automated cancellation.
  T registerTimer<T extends Timer>(T timer) {
    _timers.add(timer);
    return timer;
  }

  /// Shuts down all components and releases resources.
  void stop() {
    _isActive = false;
    
    // Stop components first (high-level teardown)
    for (final component in _components) {
      component.onStop();
    }

    // Release low-level resources
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    _subscriptions.clear();

    for (final timer in _timers) {
      timer.cancel();
    }
    _timers.clear();

    for (final manager in _syncManagers) {
      manager.dispose();
    }
    _syncManagers.clear();
  }

  void dispose() => stop();
}
