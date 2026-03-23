import 'package:drift/drift.dart';
import 'package:shared/src/data/local/database.dart';
import 'package:shared/src/data/models/rider_dto.dart';
import 'package:shared/src/domain/entities/rider.dart' as entities;
import 'package:shared/src/domain/entities/user.dart' as entities;

extension RiderDtoToDrift on RiderDto {
  RidersCompanion toDriftCompanion() {
    return RidersCompanion.insert(
      id: id,
      email: email,
      fullName: fullName,
      companyId: companyId,
      status: status,
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

extension RiderDataToEntity on Rider {
  entities.Rider toEntity() {
    return entities.Rider(
      id: id,
      email: email,
      fullName: fullName,
      companyId: companyId,
      status: entities.RiderStatusX.fromString(status),
      phoneNumber: phoneNumber,
      fcmToken: fcmToken,
      lastLat: lastLat,
      lastLng: lastLng,
      batteryLevel: batteryLevel,
      isAccepted: isAccepted,
      createdAt: createdAt,
      updatedAt: updatedAt,
      user: entities.User(
        id: id, // Use Profile ID as User ID for the UI
        email: email,
        fullName: fullName,
        isOnboarded: true,
        phoneNumber: phoneNumber,
        companyId: companyId,
        role: entities.UserRole.rider,
      ),
    );
  }
}

extension RiderEntityToDrift on entities.Rider {
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
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      localUpdatedAt: DateTime.now(),
    );
  }
}
