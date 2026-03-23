// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shared/src/data/models/company_dto.dart';
import 'package:shared/src/data/models/rider_dto.dart';
import 'package:shared/src/domain/entities/user.dart' as entities;

part 'user_dto.freezed.dart';
part 'user_dto.g.dart';

@freezed
class UserDto with _$UserDto {
  const factory UserDto({
    required String id,
    required String email,
    required String fullName,
    required bool isOnboarded,
    String? role,
    String? companyId,
    String? phoneNumber,
    RiderDto? riderProfile,
    CompanyDto? companyProfile,
    String? sessionId,
  }) = _UserDto;

  const UserDto._();

  factory UserDto.fromJson(Map<String, dynamic> json) =>
      _$UserDtoFromJson(json);

  factory UserDto.fromEntity(entities.User user) {
    return UserDto(
      id: user.id,
      email: user.email,
      fullName: user.fullName,
      isOnboarded: user.isOnboarded,
      role: user.role?.name,
      companyId: user.companyId,
      phoneNumber: user.phoneNumber,
      riderProfile: user.riderProfile != null ? RiderDto.fromEntity(user.riderProfile!) : null,
      companyProfile: user.companyProfile != null ? CompanyDto.fromEntity(user.companyProfile!) : null,
      sessionId: user.sessionId,
    );
  }

  entities.User toEntity() => entities.User(
    id: id,
    email: email,
    fullName: fullName,
    isOnboarded: isOnboarded,
    role: entities.UserRoleX.fromString(role),
    companyId: companyId,
    phoneNumber: phoneNumber,
    riderProfile: riderProfile?.toEntity(),
    companyProfile: companyProfile?.toEntity(),
    sessionId: sessionId,
  );

  static Map<String, dynamic>? toJsonFunc(UserDto? object) {
    return object?.toJson();
  }
}
