import 'package:shared/src/domain/entities/metrics.dart';
import 'package:shared/src/domain/entities/order.dart';
import 'package:shared/src/domain/events/app_event.dart';

/// Order was created
class OrderCreatedEvent extends DispatcherEvent {
  OrderCreatedEvent(this.order, super.timestamp);

  final Order order;
}

/// Order was updated (status change, rider assigned, etc.)
class OrderUpdatedEvent extends DispatcherEvent {
  OrderUpdatedEvent(this.order, super.timestamp);

  final Order order;
}

/// Rider location was updated
class RiderLocationUpdatedEvent extends DispatcherEvent {
  RiderLocationUpdatedEvent({
    required this.riderId,
    required this.lat,
    required this.lng,
    required this.batteryLevel,
    required DateTime timestamp,
  }) : super(timestamp);

  final String riderId;
  final double lat;
  final double lng;
  final int? batteryLevel;
}

/// Rider status changed (online/offline/busy)
class RiderStatusChangedEvent extends DispatcherEvent {
  RiderStatusChangedEvent({
    required this.riderId,
    required this.status,
    required DateTime timestamp,
  }) : super(timestamp);

  final String riderId;
  final String status;
}

/// Metrics were updated
class MetricsUpdatedEvent extends DispatcherEvent {
  MetricsUpdatedEvent(this.metrics, super.timestamp);

  final Metrics metrics;
}
