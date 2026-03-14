import 'package:freezed_annotation/freezed_annotation.dart';

part 'rider_location_info.freezed.dart';

@freezed
abstract class RiderLocationInfo with _$RiderLocationInfo {
  const factory RiderLocationInfo({
    required String id,
    required String fullName,
    String? imageUrl,
    double? lastLat,
    double? lastLng,
  }) = _RiderLocationInfo;
}

extension RiderLocationInfoX on RiderLocationInfo {
  bool get hasLocation => lastLat != null && lastLng != null;
}
