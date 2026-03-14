// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shared/src/domain/entities/rider_location_info.dart';

part 'rider_location_info_dto.freezed.dart';
part 'rider_location_info_dto.g.dart';

@freezed
class RiderLocationInfoDto with _$RiderLocationInfoDto {
  const factory RiderLocationInfoDto({
    required String id,
    required String fullName,
    String? imageUrl,
    double? lastLat,
    double? lastLng,
  }) = _RiderLocationInfoDto;

  const RiderLocationInfoDto._();

  factory RiderLocationInfoDto.fromJson(Map<String, dynamic> json) =>
      _$RiderLocationInfoDtoFromJson(json);

  RiderLocationInfo toEntity() => RiderLocationInfo(
    id: id,
    fullName: fullName,
    imageUrl: imageUrl,
    lastLat: lastLat,
    lastLng: lastLng,
  );
}
