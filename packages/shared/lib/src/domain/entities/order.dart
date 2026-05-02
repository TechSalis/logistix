// ignore_for_file: constant_identifier_names
import 'package:shared/shared.dart';

class Order {
  const Order({
    required this.id,
    required this.dropOffAddress,
    required this.pickupAddress,
    required this.trackingNumber,
    required this.status,
    required this.createdAt,
    this.dropOffPlaceId,
    this.dropOffLat,
    this.dropOffLng,
    this.pickupPlaceId,
    this.pickupLat,
    this.pickupLng,
    this.riderId,
    this.trackingPin,
    this.rider,
    this.companyId,
    this.assignedCompanyId,
    this.price,
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
  final String pickupAddress;
  final String trackingNumber;
  final OrderStatus status;
  final DateTime createdAt;
  final String? dropOffPlaceId;
  final double? dropOffLat;
  final double? dropOffLng;
  final String? pickupPlaceId;
  final double? pickupLat;
  final double? pickupLng;
  final String? riderId;
  final String? trackingPin;
  final Rider? rider;
  final String? companyId;
  final String? assignedCompanyId;
  final double? price;
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
    String? pickupAddress,
    String? trackingNumber,
    OrderStatus? status,
    DateTime? createdAt,
    String? dropOffPlaceId,
    double? dropOffLat,
    double? dropOffLng,
    String? pickupPlaceId,
    double? pickupLat,
    double? pickupLng,
    String? riderId,
    String? trackingPin,
    Rider? rider,
    String? companyId,
    String? assignedCompanyId,
    double? price,
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
      pickupAddress: pickupAddress ?? this.pickupAddress,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      dropOffPlaceId: dropOffPlaceId ?? this.dropOffPlaceId,
      dropOffLat: dropOffLat ?? this.dropOffLat,
      dropOffLng: dropOffLng ?? this.dropOffLng,
      pickupPlaceId: pickupPlaceId ?? this.pickupPlaceId,
      pickupLat: pickupLat ?? this.pickupLat,
      pickupLng: pickupLng ?? this.pickupLng,
      riderId: riderId ?? this.riderId,
      trackingPin: trackingPin ?? this.trackingPin,
      rider: rider ?? this.rider,
      companyId: companyId ?? this.companyId,
      assignedCompanyId: assignedCompanyId ?? this.assignedCompanyId,
      price: price ?? this.price,
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
  PENDING,
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
      case OrderStatus.PENDING:
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
      orElse: () => OrderStatus.PENDING,
    );
  }
}

extension OrderX on Order {
  bool get hasPickupPosition => pickupLat != null && pickupLng != null;
  bool get hasDropOffPosition => dropOffLat != null && dropOffLng != null;
  bool get hasLocation => hasPickupPosition || hasDropOffPosition;

  /// Returns whether the user is authorized to share this order based on their billing tier.
  bool canShare(BillingTier tier) => tier != BillingTier.free;

  /// Generates a standardized share text for this order.
  String toShareText(String trackingLink) {
    final buffer = StringBuffer()
      ..writeln('📦 Order #$trackingNumber')
      ..writeln('Status: ${status.label}');

    if (description?.isNotEmpty ?? false) {
      buffer.writeln('Description: $description');
    }

    buffer.writeln('Drop-off: $dropOffAddress');
    buffer.writeln('Pickup: $pickupAddress');

    if (dropOffPhone != null) buffer.writeln('Contact: $dropOffPhone');
    if (rider != null) buffer.writeln('Rider: ${rider!.fullName}');
    if (price != null) buffer.writeln('Price: \$${price!.toStringAsFixed(2)}');
    if (isPriority) buffer.writeln('⚡ Priority Order');

    buffer.writeln('\n🔗 Track: $trackingLink');
    return buffer.toString();
  }
}
