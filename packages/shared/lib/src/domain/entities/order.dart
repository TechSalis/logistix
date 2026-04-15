// ignore_for_file: constant_identifier_names
import 'package:shared/shared.dart';

class Order {
  const Order({
    required this.id,
    required this.dropOffAddress,
    required this.trackingNumber,
    required this.status,
    required this.createdAt,
    this.dropOffPlaceId,
    this.dropOffLat,
    this.dropOffLng,
    this.pickupAddress,
    this.pickupPlaceId,
    this.pickupLat,
    this.pickupLng,
    this.riderId,
    this.trackingCode,
    this.rider,
    this.companyId,
    this.assignedCompanyId,
    this.codAmount,
    this.description,
    this.scheduledAt,
    this.createdBy,
    this.pickupPhone,
    this.dropOffPhone,
    this.deliveredAt,
    this.updatedAt,
    this.isPriority = false,
  });

  final String id;
  final String dropOffAddress;
  final String trackingNumber;
  final OrderStatus status;
  final DateTime createdAt;
  final String? dropOffPlaceId;
  final double? dropOffLat;
  final double? dropOffLng;
  final String? pickupAddress;
  final String? pickupPlaceId;
  final double? pickupLat;
  final double? pickupLng;
  final String? riderId;
  final String? trackingCode;
  final Rider? rider;
  final String? companyId;
  final String? assignedCompanyId;
  final double? codAmount;
  final String? description;
  final DateTime? scheduledAt;
  final String? createdBy;
  final String? pickupPhone;
  final String? dropOffPhone;
  final DateTime? deliveredAt;
  final DateTime? updatedAt;
  final bool isPriority;

  Order copyWith({
    String? id,
    String? dropOffAddress,
    String? trackingNumber,
    OrderStatus? status,
    DateTime? createdAt,
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
    bool? isPriority,
  }) {
    return Order(
      id: id ?? this.id,
      dropOffAddress: dropOffAddress ?? this.dropOffAddress,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      dropOffPlaceId: dropOffPlaceId ?? this.dropOffPlaceId,
      dropOffLat: dropOffLat ?? this.dropOffLat,
      dropOffLng: dropOffLng ?? this.dropOffLng,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      pickupPlaceId: pickupPlaceId ?? this.pickupPlaceId,
      pickupLat: pickupLat ?? this.pickupLat,
      pickupLng: pickupLng ?? this.pickupLng,
      riderId: riderId ?? this.riderId,
      trackingCode: trackingCode ?? this.trackingCode,
      rider: rider ?? this.rider,
      companyId: companyId ?? this.companyId,
      assignedCompanyId: assignedCompanyId ?? this.assignedCompanyId,
      codAmount: codAmount ?? this.codAmount,
      description: description ?? this.description,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      createdBy: createdBy ?? this.createdBy,
      pickupPhone: pickupPhone ?? this.pickupPhone,
      dropOffPhone: dropOffPhone ?? this.dropOffPhone,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPriority: isPriority ?? this.isPriority,
    );
  }
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
  CREATED,
  UPDATED,
  DELETED,
  ASSIGNED,
  STATUS_CHANGED,
  LOCATION_UPDATED,
}

extension SubscriptionEventTypeX on SubscriptionEventType {
  static SubscriptionEventType fromString(String value) {
    return SubscriptionEventType.values.firstWhere(
      (e) => e.name == value.toUpperCase(),
      orElse: () => SubscriptionEventType.UPDATED,
    );
  }
}

extension OrderStatusX on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.UNASSIGNED:
        return 'Unassigned';
      case OrderStatus.ASSIGNED:
        return 'Assigned';
      case OrderStatus.EN_ROUTE:
        return 'En Route';
      case OrderStatus.DELIVERED:
        return 'Delivered';
      case OrderStatus.CANCELLED:
        return 'Cancelled';
    }
  }

  static OrderStatus fromString(String status) {
    return OrderStatus.values.firstWhere(
      (e) => e.name == status.toUpperCase(),
      orElse: () => OrderStatus.UNASSIGNED,
    );
  }
}

extension OrderX on Order {
  bool get hasPickupPosition => pickupLat != null && pickupLng != null;
  bool get hasDropOffPosition => dropOffLat != null && dropOffLng != null;
  bool get hasLocation => hasPickupPosition || hasDropOffPosition;
}
