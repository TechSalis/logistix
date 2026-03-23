// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shared/src/data/models/order_dto.dart';
import 'package:shared/src/data/models/user_dto.dart';
import 'package:shared/src/domain/entities/rider.dart';

part 'rider_dto.freezed.dart';
part 'rider_dto.g.dart';

@freezed
class RiderDto with _$RiderDto {
  const factory RiderDto({
    required String id,
    required String email,
    required String fullName,
    required String status,
    required String companyId,
    String? phoneNumber,
    String? fcmToken,
    UserDto? user,
    OrderDto? activeOrder,
    double? lastLat,
    double? lastLng,
    int? batteryLevel,
    @Default(false) bool isAccepted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _RiderDto;

  factory RiderDto.fromEntity(Rider rider) => RiderDto(
    id: rider.id,
    email: rider.email,
    fullName: rider.fullName,
    companyId: rider.companyId,
    status: rider.status.value,
    phoneNumber: rider.phoneNumber,
    fcmToken: rider.fcmToken,
    user: rider.user != null ? UserDto.fromEntity(rider.user!) : null,
    lastLat: rider.lastLat,
    lastLng: rider.lastLng,
    batteryLevel: rider.batteryLevel,
    isAccepted: rider.isAccepted,
    createdAt: rider.createdAt,
    updatedAt: rider.updatedAt,
  );

  const RiderDto._();

  factory RiderDto.fromJson(Map<String, dynamic> json) =>
      _$RiderDtoFromJson(json);

  Rider toEntity() => Rider(
    id: id,
    email: email,
    fullName: fullName,
    companyId: companyId,
    status: RiderStatusX.fromString(status),
    phoneNumber: phoneNumber,
    fcmToken: fcmToken,
    user: user?.toEntity(),
    activeOrder: activeOrder?.toEntity(),
    lastLat: lastLat,
    lastLng: lastLng,
    batteryLevel: batteryLevel,
    isAccepted: isAccepted,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}
