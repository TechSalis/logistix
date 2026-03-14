import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:logistix_ux/logistix_ux.dart';
import 'package:shared/src/domain/entities/order.dart';

part 'rider.freezed.dart';

@freezed
abstract class Rider with _$Rider {
  const factory Rider({
    required String id,
    required String fullName,
    required String email,
    required RiderStatus status,
    required String companyId,
    String? phoneNumber,
    Order? activeOrder,
    double? lastLat,
    double? lastLng,
    int? batteryLevel,
    @Default(false) bool isAccepted,
    // @Default(false) bool isIndependent,
    // String? permitUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Rider;
}

enum RiderStatus { offline, online, busy }

extension RiderStatusX on RiderStatus {
  String get value => name.capitalize;

  static RiderStatus fromString(String status) {
    switch (status.toUpperCase()) {
      case 'ONLINE':
        return RiderStatus.online;
      case 'BUSY':
        return RiderStatus.busy;
      default:
        return RiderStatus.offline;
    }
  }
}

extension RiderX on Rider {
  bool get hasLocation => lastLat != null && lastLng != null;
}
