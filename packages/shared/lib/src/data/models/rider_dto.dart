// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shared/src/data/models/order_dto.dart';
import 'package:shared/src/domain/entities/rider.dart';

part 'rider_dto.freezed.dart';
part 'rider_dto.g.dart';

@freezed
class RiderDto with _$RiderDto {
  const factory RiderDto({
    required String id,
    required String fullName,
    required String email,
    required String status,
    required String companyId,
    String? phoneNumber,
    OrderDto? activeOrder,
    double? lastLat,
    double? lastLng,
    int? batteryLevel,
    @Default(false) bool isAccepted,
    // @Default(false) bool isIndependent,
    // String? permitUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _RiderDto;

  const RiderDto._();

  factory RiderDto.fromJson(Map<String, dynamic> json) =>
      _$RiderDtoFromJson(json);

  Rider toEntity() => Rider(
    id: id,
    fullName: fullName,
    email: email,
    companyId: companyId,
    status: RiderStatusX.fromString(status),
    phoneNumber: phoneNumber,
    activeOrder: activeOrder?.toEntity(),
    lastLat: lastLat,
    lastLng: lastLng,
    batteryLevel: batteryLevel,
    isAccepted: isAccepted,
    // isIndependent: isIndependent,
    // permitUrl: permitUrl,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}
