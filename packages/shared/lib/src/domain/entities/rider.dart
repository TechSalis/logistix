import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shared/shared.dart';

part 'rider.freezed.dart';

@freezed
abstract class Rider with _$Rider {
  const factory Rider({
    required String id,
    required String email,
    required String fullName,
    required RiderStatus status,
    required String companyId,
    String? phoneNumber,
    String? fcmToken,
    User? user, // Nested for UI convenience
    Order? activeOrder,
    double? lastLat,
    double? lastLng,
    int? batteryLevel,
    @Default(false) bool isAccepted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Rider;
}

enum RiderStatus { online, busy, offline }

extension RiderStatusX on RiderStatus {
  String get value => name.toUpperCase();

  static RiderStatus fromString(String status) {
    switch (status.toUpperCase()) {
      case 'ONLINE':
        return RiderStatus.online;
      case 'BUSY':
        return RiderStatus.busy;
      case 'OFFLINE':
      default:
        return RiderStatus.offline;
    }
  }
}

extension RiderX on Rider {
  bool get hasPosition => lastLat != null && lastLng != null;
}
