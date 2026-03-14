/// Base class for all real-time events received from the backend
abstract class AppEvent {
  const AppEvent(this.timestamp);
  final DateTime timestamp;
}

/// Events for Dispatcher module
abstract class DispatcherEvent extends AppEvent {
  const DispatcherEvent(super.timestamp);
}

/// Events for Rider module
abstract class RiderEvent extends AppEvent {
  const RiderEvent(super.timestamp);
}
