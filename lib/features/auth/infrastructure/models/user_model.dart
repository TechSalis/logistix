import 'package:logistix/features/auth/domain/entities/user.dart';
import 'package:logistix/features/auth/infrastructure/models/user_data_model.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.isAnonymous,
    required super.role,
    required super.data,
  });

  factory UserModel.fromMap(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      isAnonymous: json['is_anonymous'] as bool? ?? false,
      role: _roleFromString(json['user_metadata']?['role']),
      data: UserDataModel.fromJson(json),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'is_anonymous': isAnonymous,
      'user_metadata': {'role': _roleToString(role), ...data.toMap()},
    };
  }

  static UserRole _roleFromString(String? value) {
    switch (value) {
      case 'rider':
        return UserRole.rider;
      case 'company':
        return UserRole.company;
      default:
        return UserRole.customer;
    }
  }

  static String _roleToString(UserRole role) {
    switch (role) {
      case UserRole.rider:
        return 'rider';
      case UserRole.company:
        return 'company';
      case UserRole.customer:
        return 'customer';
    }
  }
}
