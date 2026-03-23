import 'package:drift/drift.dart';
import 'package:shared/src/data/local/database.dart';
import 'package:shared/src/data/models/order_dto.dart';
import 'package:shared/src/domain/entities/order.dart' as entities;
import 'package:shared/src/domain/entities/rider.dart' as entities;

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
      codAmount: Value(codAmount),
      pickupPhone: Value(pickupPhone),
      dropOffPhone: Value(dropOffPhone),
      companyId: Value(companyId),
      assignedCompanyId: Value(assignedCompanyId),
      description: Value(description),
      createdBy: Value(createdBy),
      trackingNumber: trackingNumber,
      status: status,
      deliveredAt: Value(deliveredAt),
      createdAt: createdAt,
      updatedAt: Value(updatedAt),
      localUpdatedAt: DateTime.now(),
    );
  }
}

extension OrderDriftToEntity on Order {
  entities.Order toEntity({entities.Rider? rider}) {
    return entities.Order(
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
      codAmount: codAmount,
      pickupPhone: pickupPhone,
      dropOffPhone: dropOffPhone,
      companyId: companyId,
      assignedCompanyId: assignedCompanyId,
      description: description,
      createdBy: createdBy,
      trackingNumber: trackingNumber,
      status: entities.OrderStatusX.fromString(status),
      deliveredAt: deliveredAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

extension OrderEntityToDrift on entities.Order {
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
      codAmount: Value(codAmount),
      pickupPhone: Value(pickupPhone),
      dropOffPhone: Value(dropOffPhone),
      companyId: Value(companyId),
      assignedCompanyId: Value(assignedCompanyId),
      description: Value(description),
      createdBy: Value(createdBy),
      trackingNumber: trackingNumber,
      status: status.value,
      deliveredAt: Value(deliveredAt),
      createdAt: createdAt,
      updatedAt: Value(updatedAt),
      localUpdatedAt: DateTime.now(),
    );
  }
}
