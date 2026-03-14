// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shared/shared.dart';

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
  }) = _UserDto;

  const UserDto._();

  factory UserDto.fromJson(Map<String, dynamic> json) =>
      _$UserDtoFromJson(json);

  factory UserDto.fromEntity(User user) {
    return UserDto(
      id: user.id,
      email: user.email,
      fullName: user.fullName,
      isOnboarded: user.isOnboarded,
      role: user.role?.value,
      companyId: user.companyId,
    );
  }

  User toEntity() => User(
    id: id,
    email: email,
    fullName: fullName,
    isOnboarded: isOnboarded,
    role: UserRoleX.fromString(role),
    companyId: companyId,
  );

  static Map<String, dynamic>? toJsonFunc(UserDto? object) {
    return object?.toJson();
  }
}
