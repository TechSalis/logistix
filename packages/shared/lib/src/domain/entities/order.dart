import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shared/shared.dart';

part 'order.freezed.dart';

@freezed
abstract class Order with _$Order {
  const factory Order({
    required String id,
    required String companyId,
    required String pickupAddress,
    required String trackingNumber,
    required OrderStatus status,
    required DateTime createdAt,
    String? dropOffAddress,
    String? riderId,
    Rider? rider,
    String? items,
    double? codAmount,
    int? sequenceNumber,
    String? description,
    String? customerName,
    String? customerPhone,
    DateTime? deliveredAt,
    DateTime? updatedAt,
  }) = _Order;
}

enum OrderStatus { unassigned, assigned, enRoute, delivered, cancelled }

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
