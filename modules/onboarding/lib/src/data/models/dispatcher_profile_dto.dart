import 'package:freezed_annotation/freezed_annotation.dart';

part 'dispatcher_profile_dto.freezed.dart';
part 'dispatcher_profile_dto.g.dart';

@freezed
class DispatcherProfileDto with _$DispatcherProfileDto {
  const factory DispatcherProfileDto({
    required String companyName,
    required String phoneNumber,
    required String address,
    required String cac,
  }) = _DispatcherProfileDto;

  factory DispatcherProfileDto.fromJson(Map<String, dynamic> json) =>
      _$DispatcherProfileDtoFromJson(json);
}
