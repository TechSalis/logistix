import 'package:flutter/foundation.dart';
import 'package:shared/src/domain/entities/user.dart';

@immutable
class DispatcherDto {
  const DispatcherDto({
    required this.id,
    required this.email,
    required this.fullName,
    this.companyId,
    this.phoneNumber,
  });

  factory DispatcherDto.fromJson(Map<String, dynamic> json) {
    return DispatcherDto(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['fullName'] as String,
      companyId: json['companyId'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
    );
  }

  final String id;
  final String email;
  final String fullName;
  final String? companyId;
  final String? phoneNumber;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      if (companyId != null) 'companyId': companyId,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
    };
  }

  User toUserEntity() => User(
        id: id,
        email: email,
        fullName: fullName,
        isOnboarded: true,
        role: UserRole.DISPATCHER,
        companyId: companyId,
        phoneNumber: phoneNumber,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DispatcherDto &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email;

  @override
  int get hashCode => id.hashCode ^ email.hashCode;
}
