import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared/shared.dart';

part 'rider_event.freezed.dart';

@freezed
class RiderEvent with _$RiderEvent {
  const factory RiderEvent.fetchProfile() = FetchProfile;
  const factory RiderEvent.refreshStatus() = RefreshStatus;
  const factory RiderEvent.fetchOrders({
    List<OrderStatus>? status,
    int? limit,
    int? offset,
  }) = FetchOrders;
  const factory RiderEvent.orderAssigned(Order order) = OrderAssigned;
  const factory RiderEvent.orderUpdated(Order order) = OrderUpdated;
  const factory RiderEvent.orderUnassigned(String orderId) = OrderUnassigned;
  const factory RiderEvent.metricsUpdated(RiderMetrics metrics) = MetricsUpdated;
  const factory RiderEvent.locationUpdated(Position position) = LocationUpdated;
}
