// ignore_for_file: constant_identifier_names

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shared/shared.dart';

part 'order.freezed.dart';

@freezed
abstract class Order with _$Order {
  const factory Order({
    required String id,
    required String dropOffAddress,
    required String trackingNumber,
    required OrderStatus status,
    required DateTime createdAt,
    String? dropOffPlaceId,
    double? dropOffLat,
    double? dropOffLng,
    String? pickupAddress,
    String? pickupPlaceId,
    double? pickupLat,
    double? pickupLng,
    String? riderId,
    String? trackingCode,
    Rider? rider,
    String? companyId,
    String? assignedCompanyId,
    double? codAmount,
    String? description,
    DateTime? scheduledAt,
    String? createdBy,
    String? pickupPhone,
    String? dropOffPhone,
    DateTime? deliveredAt,
    DateTime? updatedAt,
  }) = _Order;
}

enum OrderStatus {
  UNASSIGNED,
  ASSIGNED,
  EN_ROUTE,
  DELIVERED,
  CANCELLED;

  bool get isCompleted {
    return this == OrderStatus.DELIVERED || this == OrderStatus.CANCELLED;
  }
}

enum SubscriptionEventType {
  created,
  updated,
  deleted,
  assigned,
  status_changed,
  location_updated,
}

extension OrderStatusX on OrderStatus {
  String get value => name;

  String get label => value.replaceAll('_', ' ');

  static OrderStatus fromString(String status) {
    return OrderStatus.values.firstWhere(
      (e) => e.name == status,
      orElse: () => OrderStatus.UNASSIGNED,
    );
  }
}

extension OrderX on Order {
  bool get hasPickupPosition => pickupLat != null && pickupLng != null;
  bool get hasDropOffPosition => dropOffLat != null && dropOffLng != null;
  bool get hasLocation => hasPickupPosition || hasDropOffPosition;
}
