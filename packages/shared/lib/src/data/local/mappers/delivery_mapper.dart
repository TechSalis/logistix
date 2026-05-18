import 'package:drift/drift.dart';
import 'package:shared/src/data/local/database.dart';
import 'package:shared/src/data/models/delivery_dto.dart';
import 'package:shared/src/domain/entities/delivery.dart' as delivery_entities;
import 'package:shared/src/domain/entities/rider.dart' as rider_entities;

extension DeliveryDtoToDrift on DeliveryDto {
  DeliveriesCompanion toDriftCompanion() {
    return DeliveriesCompanion(
      id: Value(id),
      pickupAddress: Value(pickupAddress),
      pickupLat: Value(pickupLat),
      pickupLng: Value(pickupLng),
      pickupPlaceId: Value(pickupPlaceId),
      dropOffAddress: Value(dropOffAddress),
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
      trackingNumber: Value(trackingNumber),
      status: Value(status),
      deliveredAt: Value(deliveredAt),
      scheduledAt: Value(scheduledAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      paymentMethod: Value(paymentMethod),
    );
  }
}

extension DeliveryDriftToEntity on DeliveryRow {
  delivery_entities.Delivery toEntity({rider_entities.Rider? rider}) {
    return delivery_entities.Delivery(
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
      status: delivery_entities.DeliveryStatusX.fromString(status),
      deliveredAt: deliveredAt,
      scheduledAt: scheduledAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
      paymentMethod: paymentMethod != null ? delivery_entities.PaymentMethod.fromString(paymentMethod!) : null,
    );
  }
}

extension DeliveryEntityToDrift on delivery_entities.Delivery {
  DeliveriesCompanion toDriftCompanion() {
    return DeliveriesCompanion(
      id: Value(id),
      pickupAddress: Value(pickupAddress),
      pickupLat: Value(pickupLat),
      pickupLng: Value(pickupLng),
      pickupPlaceId: Value(pickupPlaceId),
      dropOffAddress: Value(dropOffAddress),
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
      trackingNumber: Value(trackingNumber),
      status: Value(status.name),
      deliveredAt: Value(deliveredAt),
      scheduledAt: Value(scheduledAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      paymentMethod: Value(paymentMethod?.name),
    );
  }
}
