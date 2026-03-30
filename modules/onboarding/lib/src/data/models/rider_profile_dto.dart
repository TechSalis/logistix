import 'package:freezed_annotation/freezed_annotation.dart';

part 'rider_profile_dto.freezed.dart';
part 'rider_profile_dto.g.dart';

@freezed
abstract class RiderProfileDto with _$RiderProfileDto {
  const factory RiderProfileDto({
    required String phoneNumber,
    required String registrationNumber,
    String? companyId,
  }) = _RiderProfileDto;

  factory RiderProfileDto.fromJson(Map<String, dynamic> json) =>
      _$RiderProfileDtoFromJson(json);
}
