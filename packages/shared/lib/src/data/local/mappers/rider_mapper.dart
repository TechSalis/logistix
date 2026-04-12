import 'package:drift/drift.dart';
import 'package:shared/src/data/local/database.dart';
import 'package:shared/src/data/models/rider_dto.dart';
import 'package:shared/src/domain/entities/rider.dart' as rider_entities;

extension RiderDtoToDrift on RiderDto {
  RidersCompanion toDriftCompanion() {
    return RidersCompanion.insert(
      id: id,
      email: email,
      fullName: fullName,
      companyId: companyId,
      status: status,
      permitStatus: Value(permitStatus),
      phoneNumber: Value(phoneNumber),
      fcmToken: Value(fcmToken),
      isAccepted: Value(isAccepted),
      lastLat: Value(lastLat),
      lastLng: Value(lastLng),
      batteryLevel: Value(batteryLevel),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      localUpdatedAt: DateTime.now(),
    );
  }
}

extension RiderDataToEntity on RiderRow {
  rider_entities.Rider toEntity() {
    return rider_entities.Rider(
      id: id,
      email: email,
      fullName: fullName,
      companyId: companyId,
      status: rider_entities.RiderStatusX.fromString(status),
      phoneNumber: phoneNumber,
      fcmToken: fcmToken,
      lastLat: lastLat,
      lastLng: lastLng,
      batteryLevel: batteryLevel,
      isAccepted: isAccepted,
      permitStatus: rider_entities.PermitStatusX.fromString(permitStatus),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

extension RiderEntityToDrift on rider_entities.Rider {
  RidersCompanion toDriftCompanion() {
    return RidersCompanion.insert(
      id: id,
      email: email,
      fullName: fullName,
      companyId: companyId,
      status: status.value,
      phoneNumber: Value(phoneNumber),
      fcmToken: Value(fcmToken),
      lastLat: Value(lastLat),
      lastLng: Value(lastLng),
      batteryLevel: Value(batteryLevel),
      isAccepted: Value(isAccepted),
      permitStatus: Value(permitStatus.value),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      localUpdatedAt: DateTime.now(),
    );
  }
}
