import 'package:drift/drift.dart';
import 'package:shared/src/data/local/database.dart';
import 'package:shared/src/data/models/order_dto.dart';
import 'package:shared/src/domain/entities/order.dart' as order_entities;
import 'package:shared/src/domain/entities/rider.dart' as rider_entities;

extension OrderDtoToDrift on OrderDto {
  OrdersCompanion toDriftCompanion() {
    return OrdersCompanion.insert(
      id: id,
      pickupAddress: Value(pickupAddress),
      pickupLat: Value(pickupLat),
      pickupLng: Value(pickupLng),
      pickupPlaceId: Value(pickupPlaceId),
      dropOffAddress: dropOffAddress,
      dropOffLat: Value(dropOffLat),
      dropOffLng: Value(dropOffLng),
      dropOffPlaceId: Value(dropOffPlaceId),
      riderId: Value(riderId),
      price: Value(price),
      pickupPhone: Value(pickupPhone),
      dropOffPhone: Value(dropOffPhone),
      companyId: Value(companyId),
      assignedCompanyId: Value(assignedCompanyId),
      description: Value(description),
      createdBy: Value(createdBy),
      trackingNumber: trackingNumber,
      status: status,
      deliveredAt: Value(deliveredAt),
      scheduledAt: Value(scheduledAt),
      createdAt: createdAt,
      updatedAt: Value(updatedAt),
      localUpdatedAt: DateTime.now(),
    );
  }
}

extension OrderDriftToEntity on OrderRow {
  order_entities.Order toEntity({rider_entities.Rider? rider}) {
    return order_entities.Order(
      id: id,
      pickupAddress: pickupAddress,
      pickupLat: pickupLat,
      pickupLng: pickupLng,
      pickupPlaceId: pickupPlaceId,
      dropOffAddress: dropOffAddress,
      dropOffLat: dropOffLat,
      dropOffLng: dropOffLng,
      dropOffPlaceId: dropOffPlaceId,
      riderId: riderId,
      rider: rider,
      price: price,
      pickupPhone: pickupPhone,
      dropOffPhone: dropOffPhone,
      companyId: companyId,
      assignedCompanyId: assignedCompanyId,
      description: description,
      createdBy: createdBy,
      trackingNumber: trackingNumber,
      status: order_entities.OrderStatusX.fromString(status),
      deliveredAt: deliveredAt,
      scheduledAt: scheduledAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

extension OrderEntityToDrift on order_entities.Order {
  OrdersCompanion toDriftCompanion() {
    return OrdersCompanion.insert(
      id: id,
      pickupAddress: Value(pickupAddress),
      pickupLat: Value(pickupLat),
      pickupLng: Value(pickupLng),
      pickupPlaceId: Value(pickupPlaceId),
      dropOffAddress: dropOffAddress,
      dropOffLat: Value(dropOffLat),
      dropOffLng: Value(dropOffLng),
      dropOffPlaceId: Value(dropOffPlaceId),
      riderId: Value(riderId),
      price: Value(price),
      pickupPhone: Value(pickupPhone),
      dropOffPhone: Value(dropOffPhone),
      companyId: Value(companyId),
      assignedCompanyId: Value(assignedCompanyId),
      description: Value(description),
      createdBy: Value(createdBy),
      trackingNumber: trackingNumber,
      status: status.name,
      deliveredAt: Value(deliveredAt),
      scheduledAt: Value(scheduledAt),
      createdAt: createdAt,
      updatedAt: Value(updatedAt),
      localUpdatedAt: DateTime.now(),
    );
  }
}
