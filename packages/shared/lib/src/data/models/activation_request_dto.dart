import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shared/src/domain/entities/platform.dart';

part 'activation_request_dto.freezed.dart';
part 'activation_request_dto.g.dart';

@freezed
abstract class ActivationRequestDto with _$ActivationRequestDto {
  const factory ActivationRequestDto({
    required String email,
    required String name,
    required String phone,
    required Platform platform,
  }) = _ActivationRequestDto;

  factory ActivationRequestDto.fromJson(Map<String, dynamic> json) =>
      _$ActivationRequestDtoFromJson(json);
}
