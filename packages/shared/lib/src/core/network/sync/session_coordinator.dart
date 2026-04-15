import 'dart:async';
import 'package:adapters/adapters.dart';
import 'package:flutter/widgets.dart';

/// Base interface for all modular session operations (Sync, Heartbeat, Chat, etc.)
abstract class SessionComponent {
  /// Unique identifier for this component (used for logging and collision avoidance)
  String get id;

  /// Triggered when the global session starts or resumes.
  Future<void> start();

  /// Triggered when the global session stops or is destroyed.
  Future<void> stop();

  /// Triggered manually or periodically to perform data synchronization.
  Future<void> sync() async {}

  /// Optional: Triggered during app foreground/background transitions.
  void onLifecycleChanged(AppLifecycleState state) {}
}

/// A centralized host that manages the lifecycle and resources of multiple [SessionComponent]s.
class SessionCoordinator {
  SessionCoordinator({List<SessionComponent>? components})
    : _components = components ?? [];

  final List<SessionComponent> _components;
  bool _isActive = false;

  List<SessionComponent> get components => List.unmodifiable(_components);

  void addComponent(SessionComponent component) {
    _components.add(component);
    if (_isActive) {
      component.start();
    }
  }

  /// Returns whether the session is currently active and components are running.
  bool get isActive => _isActive;

  /// Registers and starts all session components.
  Future<void> start() async {
    if (_isActive) return;
    _isActive = true;

    for (final component in _components) {
      try {
        await component.start();
      } catch (e) {
        appLogger.error(
          '[SessionCoordinator] Failed to start component ${component.id}: $e',
        );
      }
    }
  }

  /// Triggers a synchronization event across all registered components.
  Future<void> sync() async {
    if (!_isActive) return;
    for (final component in _components) {
      try {
        await component.sync();
      } catch (e) {
        appLogger.error(
          '[SessionCoordinator] Sync failed for ${component.id}: $e',
        );
      }
    }
  }

  /// Stops all registered components and releases their resources.
  Future<void> stop() async {
    if (!_isActive) return;
    _isActive = false;

    for (final component in _components) {
      try {
        await component.stop();
      } catch (e) {
        appLogger.error(
          '[SessionCoordinator] Failed to stop component ${component.id}: $e',
        );
      }
    }
  }

  /// Propagates app lifecycle changes to all components.
  void handleLifecycleChange(AppLifecycleState state) {
    if (!_isActive) return;
    for (final component in _components) {
      component.onLifecycleChanged(state);
    }
  }

  /// Convenience method to help with Hot Restart cleanup.
  Future<void> dispose() => stop();
}
