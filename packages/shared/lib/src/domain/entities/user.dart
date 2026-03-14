import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';

@freezed
abstract class User with _$User {
  const factory User({
    required String id,
    required String email,
    required String fullName,
    required bool isOnboarded,
    UserRole? role,
    String? companyId,
  }) = _User;
}

enum UserRole { rider, dispatcher }

extension UserRoleX on UserRole {
  String get value => name.toLowerCase();

  static UserRole? fromString(String? role) {
    if (role == null) return null;
    try {
      return UserRole.values.firstWhere(
        (e) => e.name.toLowerCase() == role.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }
}
