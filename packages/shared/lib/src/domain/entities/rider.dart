import 'package:shared/shared.dart';

class Rider {
  const Rider({
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
    this.permitStatus = PermitStatus.PENDING,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String email;
  final String fullName;
  final RiderStatus status;
  final String companyId;
  final String? phoneNumber;
  final String? fcmToken;
  final Order? activeOrder;
  final double? lastLat;
  final double? lastLng;
  final int? batteryLevel;
  final bool isAccepted;
  final PermitStatus permitStatus;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Rider copyWith({
    String? id,
    String? email,
    String? fullName,
    String? companyId,
    RiderStatus? status,
    String? phoneNumber,
    String? fcmToken,
    double? lastLat,
    double? lastLng,
    int? batteryLevel,
    bool? isAccepted,
    PermitStatus? permitStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Rider(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      companyId: companyId ?? this.companyId,
      status: status ?? this.status,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      fcmToken: fcmToken ?? this.fcmToken,
      lastLat: lastLat ?? this.lastLat,
      lastLng: lastLng ?? this.lastLng,
      batteryLevel: batteryLevel ?? this.batteryLevel,
      isAccepted: isAccepted ?? this.isAccepted,
      permitStatus: permitStatus ?? this.permitStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

enum RiderStatus { ONLINE, BUSY, OFFLINE }

enum PermitStatus { PENDING, APPROVED, REJECTED }

extension PermitStatusX on PermitStatus {
  String get value => name;
  
  static PermitStatus fromString(String status) {
    switch (status.toUpperCase()) {
      case 'APPROVED':
        return PermitStatus.APPROVED;
      case 'REJECTED':
        return PermitStatus.REJECTED;
      case 'PENDING':
      default:
        return PermitStatus.PENDING;
    }
  }
}

extension RiderStatusX on RiderStatus {
  String get value => name;
  String get label {
    switch (this) {
      case RiderStatus.ONLINE:
        return 'Online';
      case RiderStatus.BUSY:
        return 'Busy';
      case RiderStatus.OFFLINE:
        return 'Offline';
    }
  }

  static RiderStatus fromString(String status) {
    switch (status.toUpperCase()) {
      case 'ONLINE':
        return RiderStatus.ONLINE;
      case 'BUSY':
        return RiderStatus.BUSY;
      case 'OFFLINE':
      default:
        return RiderStatus.OFFLINE;
    }
  }
}

extension RiderX on Rider {
  bool get hasLocation => lastLat != null && lastLng != null;
}
