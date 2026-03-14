import 'dart:async';

import 'package:shared/shared.dart';
import 'package:shared/src/core/extensions/stream_extension.dart';
import 'package:shared/src/domain/events/dispatcher_events.dart' as dispatcher;
import 'package:shared/src/domain/events/rider_events.dart' as rider;

/// Central manager for all real-time events from the backend
/// Maintains a single WebSocket connection and distributes events
class AppEventStreamManager {
  AppEventStreamManager(this._dataSource);
  final EventStreamRemoteDataSource _dataSource;

  StreamSubscription<dynamic>? _subscription;
  final _eventController = StreamController<AppEvent>.broadcast();

  /// Stream of all events
  Stream<AppEvent> get events => _eventController.stream;

  /// Type-safe dispatcher event streams
  Stream<dispatcher.OrderCreatedEvent> get orderCreated =>
      events.whereType<dispatcher.OrderCreatedEvent>();

  Stream<dispatcher.OrderUpdatedEvent> get dispatcherOrderUpdated =>
      events.whereType<dispatcher.OrderUpdatedEvent>();

  Stream<dispatcher.RiderLocationUpdatedEvent> get riderLocationUpdated =>
      events.whereType<dispatcher.RiderLocationUpdatedEvent>();

  Stream<dispatcher.RiderStatusChangedEvent> get riderStatusChanged =>
      events.whereType<dispatcher.RiderStatusChangedEvent>();

  Stream<dispatcher.MetricsUpdatedEvent> get metricsUpdated =>
      events.whereType<dispatcher.MetricsUpdatedEvent>();

  /// Type-safe rider event streams
  Stream<rider.OrderAssignedEvent> get orderAssigned =>
      events.whereType<rider.OrderAssignedEvent>();

  Stream<rider.OrderUpdatedEvent> get riderOrderUpdated =>
      events.whereType<rider.OrderUpdatedEvent>();

  Stream<rider.OrderUnassignedEvent> get orderUnassigned =>
      events.whereType<rider.OrderUnassignedEvent>();

  Stream<rider.StatusChangeRequestEvent> get statusChangeRequest =>
      events.whereType<rider.StatusChangeRequestEvent>();

  Stream<rider.RiderMetricsUpdatedEvent> get riderMetricsUpdated =>
      events.whereType<rider.RiderMetricsUpdatedEvent>();

  /// Start listening to dispatcher events
  Future<void> startDispatcherStream(String companyId) async {
    unawaited(_subscription?.cancel());

    final stream = _dataSource.subscribeToDispatcherEvents(companyId);

    _subscription = stream.listen((Map<String, dynamic> eventData) {
      final event = _parseDispatcherEvent(eventData);
      if (event != null) {
        _eventController.add(event);
      }
    }, onError: _eventController.addError);
  }

  /// Start listening to rider events
  Future<void> startRiderStream(String riderId) async {
    unawaited(_subscription?.cancel());

    final stream = _dataSource.subscribeToRiderEvents(riderId);

    _subscription = stream.listen((Map<String, dynamic> eventData) {
      final event = _parseRiderEvent(eventData);
      if (event != null) {
        _eventController.add(event);
      }
    }, onError: _eventController.addError);
  }

  /// Parse dispatcher event from GraphQL response
  AppEvent? _parseDispatcherEvent(Map<String, dynamic>? data) {
    if (data == null || data.isEmpty) return null;

    final typename = data['__typename'] as String?;
    final timestampMs = data['timestamp'] as int?;
    if (typename == null || timestampMs == null) return null;

    final timestamp = DateTime.fromMillisecondsSinceEpoch(timestampMs);

    switch (typename) {
      case 'OrderCreatedEvent':
        final orderData = data['order'] as Map<String, dynamic>?;
        if (orderData == null) return null;
        return dispatcher.OrderCreatedEvent(
          OrderDto.fromJson(orderData).toEntity(),
          timestamp,
        );

      case 'OrderUpdatedEvent':
        final orderData = data['order'] as Map<String, dynamic>?;
        if (orderData == null) return null;
        return dispatcher.OrderUpdatedEvent(
          OrderDto.fromJson(orderData).toEntity(),
          timestamp,
        );

      case 'RiderLocationUpdatedEvent':
        return dispatcher.RiderLocationUpdatedEvent(
          riderId: data['riderId'] as String,
          lat: (data['lat'] as num).toDouble(),
          lng: (data['lng'] as num).toDouble(),
          batteryLevel: data['batteryLevel'] as int?,
          timestamp: timestamp,
        );

      case 'RiderStatusChangedEvent':
        return dispatcher.RiderStatusChangedEvent(
          riderId: data['riderId'] as String,
          status: data['status'] as String,
          timestamp: timestamp,
        );

      case 'MetricsUpdatedEvent':
        final metricsData = data['metrics'] as Map<String, dynamic>?;
        if (metricsData == null) return null;
        return dispatcher.MetricsUpdatedEvent(
          MetricsDto.fromJson(metricsData).toEntity(),
          timestamp,
        );

      default:
        return null;
    }
  }

  /// Parse rider event from GraphQL response
  AppEvent? _parseRiderEvent(Map<String, dynamic>? data) {
    if (data == null || data.isEmpty) return null;

    final typename = data['__typename'] as String?;
    final timestampMs = data['timestamp'] as int?;
    if (typename == null || timestampMs == null) return null;

    final timestamp = DateTime.fromMillisecondsSinceEpoch(timestampMs);

    switch (typename) {
      case 'OrderAssignedEvent':
        final orderData = data['order'] as Map<String, dynamic>?;
        if (orderData == null) return null;
        return rider.OrderAssignedEvent(
          OrderDto.fromJson(orderData).toEntity(),
          timestamp,
        );

      case 'OrderUpdatedEvent':
        final orderData = data['order'] as Map<String, dynamic>?;
        if (orderData == null) return null;
        return rider.OrderUpdatedEvent(
          OrderDto.fromJson(orderData).toEntity(),
          timestamp,
        );

      case 'OrderUnassignedEvent':
        return rider.OrderUnassignedEvent(
          orderId: data['orderId'] as String,
          reason: data['reason'] as String,
          timestamp: timestamp,
        );

      case 'StatusChangeRequestEvent':
        return rider.StatusChangeRequestEvent(
          newStatus: data['newStatus'] as String,
          reason: data['reason'] as String,
          timestamp: timestamp,
        );

      case 'RiderMetricsUpdatedEvent':
        final metricsData = data['metrics'] as Map<String, dynamic>?;
        if (metricsData == null) return null;
        return rider.RiderMetricsUpdatedEvent(
          RiderMetricsDto.fromJson(metricsData).toEntity(),
          timestamp,
        );

      default:
        return null;
    }
  }

  /// Stop listening to events and clean up
  Future<void> stop() async {
    await _subscription?.cancel();
    _subscription = null;
    await _eventController.close();
  }

  /// Check if currently subscribed
  bool get isActive => _subscription != null && !_eventController.isClosed;
}
