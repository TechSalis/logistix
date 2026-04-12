import 'package:shared/src/data/models/order_dto.dart';
import 'package:shared/src/domain/entities/rider.dart';

class RiderDto {
  const RiderDto({
    required this.id,
    required this.email,
    required this.fullName,
    required this.status,
    required this.companyId,
    this.phoneNumber,
    this.fcmToken,
    this.activeOrder,
    this.lastLat,
    this.lastLng,
    this.batteryLevel,
    this.isAccepted = false,
    this.permitStatus = 'PENDING',
    this.createdAt,
    this.updatedAt,
  });

  factory RiderDto.fromEntity(Rider rider) => RiderDto(
    id: rider.id,
    email: rider.email,
    fullName: rider.fullName,
    companyId: rider.companyId,
    status: rider.status.value,
    phoneNumber: rider.phoneNumber,
    fcmToken: rider.fcmToken,
    lastLat: rider.lastLat,
    lastLng: rider.lastLng,
    batteryLevel: rider.batteryLevel,
    isAccepted: rider.isAccepted,
    permitStatus: rider.permitStatus.value,
    createdAt: rider.createdAt,
    updatedAt: rider.updatedAt,
  );

  factory RiderDto.fromJson(Map<String, dynamic> json) {
    return RiderDto(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['fullName'] as String,
      status: json['status'] as String,
      companyId: json['companyId'] as String,
      phoneNumber: json['phoneNumber'] as String?,
      fcmToken: json['fcmToken'] as String?,
      activeOrder: json['activeOrder'] != null
          ? OrderDto.fromJson(json['activeOrder'] as Map<String, dynamic>)
          : null,
      lastLat: (json['lastLat'] as num?)?.toDouble(),
      lastLng: (json['lastLng'] as num?)?.toDouble(),
      batteryLevel: json['batteryLevel'] as int?,
      isAccepted: json['isAccepted'] as bool? ?? false,
      permitStatus: json['permitStatus'] as String? ?? 'PENDING',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  final String id;
  final String email;
  final String fullName;
  final String status;
  final String companyId;
  final String? phoneNumber;
  final String? fcmToken;
  final OrderDto? activeOrder;
  final double? lastLat;
  final double? lastLng;
  final int? batteryLevel;
  final bool isAccepted;
  final String permitStatus;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'status': status,
      'companyId': companyId,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
      if (fcmToken != null) 'fcmToken': fcmToken,
      if (activeOrder != null) 'activeOrder': activeOrder!.toJson(),
      if (lastLat != null) 'lastLat': lastLat,
      if (lastLng != null) 'lastLng': lastLng,
      if (batteryLevel != null) 'batteryLevel': batteryLevel,
      'isAccepted': isAccepted,
      'permitStatus': permitStatus,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  Rider toEntity() => Rider(
    id: id,
    email: email,
    fullName: fullName,
    companyId: companyId,
    status: RiderStatusX.fromString(status),
    phoneNumber: phoneNumber,
    fcmToken: fcmToken,
    activeOrder: activeOrder?.toEntity(),
    lastLat: lastLat,
    lastLng: lastLng,
    batteryLevel: batteryLevel,
    isAccepted: isAccepted,
    permitStatus: PermitStatusX.fromString(permitStatus),
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}
