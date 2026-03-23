import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shared/shared.dart';

part 'order.freezed.dart';

@freezed
abstract class Order with _$Order {
  const factory Order({
    required String id,
    String? pickupAddress,
    String? pickupPlaceId,
    double? pickupLat,
    double? pickupLng,
    required String dropOffAddress,
    String? dropOffPlaceId,
    double? dropOffLat,
    double? dropOffLng,
    required String trackingNumber,
    required OrderStatus status,
    required DateTime createdAt,
    String? riderId,
    Rider? rider,
    double? codAmount,
    String? description,
    String? pickupPhone,
    String? dropOffPhone,
    DateTime? deliveredAt,
    DateTime? updatedAt,
  }) = _Order;
}

enum OrderStatus {
  unassigned,
  assigned,
  enRoute,
  delivered,
  cancelled;

  bool get isCompleted {
    return this == OrderStatus.delivered || this == OrderStatus.cancelled;
  }
}

extension OrderStatusX on OrderStatus {
  String get value {
    switch (this) {
      case OrderStatus.unassigned:
        return 'UNASSIGNED';
      case OrderStatus.assigned:
        return 'ASSIGNED';
      case OrderStatus.enRoute:
        return 'EN_ROUTE';
      case OrderStatus.delivered:
        return 'DELIVERED';
      case OrderStatus.cancelled:
        return 'CANCELLED';
    }
  }

  String get label => value.replaceAll('_', ' ');

  static OrderStatus fromString(String status) {
    switch (status.toUpperCase()) {
      case 'UNASSIGNED':
        return OrderStatus.unassigned;
      case 'ASSIGNED':
        return OrderStatus.assigned;
      case 'EN_ROUTE':
        return OrderStatus.enRoute;
      case 'DELIVERED':
        return OrderStatus.delivered;
      case 'CANCELLED':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.unassigned;
    }
  }
}

extension OrderX on Order {
  bool get hasPickupPosition => pickupLat != null && pickupLng != null;
  bool get hasDropOffPosition => dropOffLat != null && dropOffLng != null;
  bool get hasPosition => hasPickupPosition || hasDropOffPosition;
}
