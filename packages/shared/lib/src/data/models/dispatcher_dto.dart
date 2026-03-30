import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shared/src/domain/entities/user.dart';

part 'dispatcher_dto.freezed.dart';
part 'dispatcher_dto.g.dart';

@freezed
abstract class DispatcherDto with _$DispatcherDto {
  const factory DispatcherDto({
    required String id,
    required String email,
    required String fullName,
    String? companyId,
    String? phoneNumber,
  }) = _DispatcherDto;

  factory DispatcherDto.fromJson(Map<String, dynamic> json) =>
      _$DispatcherDtoFromJson(json);

  const DispatcherDto._();

  User toUserEntity() => User(
    id: id,
    email: email,
    fullName: fullName,
    isOnboarded: true,
    role: UserRole.dispatcher,
    companyId: companyId,
    phoneNumber: phoneNumber,
  );
}
