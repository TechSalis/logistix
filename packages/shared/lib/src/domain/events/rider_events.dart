import 'package:shared/src/domain/entities/order.dart';
import 'package:shared/src/domain/entities/rider_metrics.dart';
import 'package:shared/src/domain/events/app_event.dart';

/// Order was assigned to this rider
class OrderAssignedEvent extends RiderEvent {
  OrderAssignedEvent(this.order, super.timestamp);

  final Order order;
}

/// Order was updated (status change, details change, etc.)
class OrderUpdatedEvent extends RiderEvent {
  OrderUpdatedEvent(this.order, super.timestamp);

  final Order order;
}

/// Order was unassigned from this rider
class OrderUnassignedEvent extends RiderEvent {
  OrderUnassignedEvent({
    required this.orderId,
    required this.reason,
    required DateTime timestamp,
  }) : super(timestamp);

  final String orderId;
  final String reason;
}

/// Backend requested status change (e.g., auto-offline)
class StatusChangeRequestEvent extends RiderEvent {
  StatusChangeRequestEvent({
    required this.newStatus,
    required this.reason,
    required DateTime timestamp,
  }) : super(timestamp);

  final String newStatus;
  final String reason;
}

/// Rider metrics were updated
class RiderMetricsUpdatedEvent extends RiderEvent {
  RiderMetricsUpdatedEvent(this.metrics, super.timestamp);

  final RiderMetrics metrics;
}
