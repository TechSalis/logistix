// ignore_for_file: constant_identifier_names
import 'package:shared/shared.dart';

class User {
  const User({
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
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String email;
  final String fullName;
  final bool isOnboarded;
  final UserRole? role;
  final String? companyId;
  final String? phoneNumber;
  final Rider? riderProfile;
  final Company? companyProfile;
  final String? sessionId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  User copyWith({
    String? id,
    String? email,
    String? fullName,
    bool? isOnboarded,
    UserRole? role,
    String? companyId,
    String? phoneNumber,
    Rider? riderProfile,
    Company? companyProfile,
    String? sessionId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      isOnboarded: isOnboarded ?? this.isOnboarded,
      role: role ?? this.role,
      companyId: companyId ?? this.companyId,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      riderProfile: riderProfile ?? this.riderProfile,
      companyProfile: companyProfile ?? this.companyProfile,
      sessionId: sessionId ?? this.sessionId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

enum UserRole { RIDER, DISPATCHER, CUSTOMER }

extension UserRoleX on UserRole {
  static UserRole fromString(String role) {
    return UserRole.values.firstWhere((e) => e.name == role.toUpperCase());
  }
}
