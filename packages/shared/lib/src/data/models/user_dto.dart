import 'package:flutter/foundation.dart';
import 'package:shared/src/data/models/company_dto.dart';
import 'package:shared/src/data/models/rider_dto.dart';
import 'package:shared/src/domain/entities/user.dart' as entities;

@immutable
class UserDto {
  const UserDto({
    required this.id,
    required this.email,
    required this.fullName,
    required this.isOnboarded,
    this.role,
    this.companyId,
    this.phoneNumber,
    this.riderProfile,
    this.companyProfile,
    this.sessionId,
    this.fcmToken,
    this.createdAt,
    this.updatedAt,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['fullName'] as String,
      isOnboarded: json['isOnboarded'] as bool? ?? false,
      role: json['role'] as String?,
      companyId: json['companyId'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      riderProfile: json['riderProfile'] != null
          ? RiderDto.fromJson(json['riderProfile'] as Map<String, dynamic>)
          : null,
      companyProfile: json['companyProfile'] != null
          ? CompanyDto.fromJson(json['companyProfile'] as Map<String, dynamic>)
          : null,
      sessionId: json['sessionId'] as String?,
      fcmToken: json['fcmToken'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  factory UserDto.fromEntity(entities.User user) {
    return UserDto(
      id: user.id,
      email: user.email,
      fullName: user.fullName,
      isOnboarded: user.isOnboarded,
      role: user.role?.name,
      companyId: user.companyId,
      phoneNumber: user.phoneNumber,
      riderProfile: user.riderProfile != null
          ? RiderDto.fromEntity(user.riderProfile!)
          : null,
      companyProfile: user.companyProfile != null
          ? CompanyDto.fromEntity(user.companyProfile!)
          : null,
      sessionId: user.sessionId,
      fcmToken: user.fcmToken,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
    );
  }

  static Map<String, dynamic>? toJsonFunc(UserDto? user) => user?.toJson();

  final String id;
  final String email;
  final String fullName;
  final bool isOnboarded;
  final String? role;
  final String? companyId;
  final String? phoneNumber;
  final RiderDto? riderProfile;
  final CompanyDto? companyProfile;
  final String? sessionId;
  final String? fcmToken;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'isOnboarded': isOnboarded,
      if (role != null) 'role': role,
      if (companyId != null) 'companyId': companyId,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
      if (riderProfile != null) 'riderProfile': riderProfile!.toJson(),
      if (companyProfile != null) 'companyProfile': companyProfile!.toJson(),
      if (sessionId != null) 'sessionId': sessionId,
      if (fcmToken != null) 'fcmToken': fcmToken,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
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
    fcmToken: fcmToken,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserDto &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email &&
          isOnboarded == other.isOnboarded;

  @override
  int get hashCode => id.hashCode ^ email.hashCode ^ isOnboarded.hashCode;
}
