import 'package:logistix/features/auth/domain/entities/user_data.dart';
import 'package:logistix/features/auth/domain/entities/user_session.dart';

class UserDataModel extends UserData {
  const UserDataModel({
    super.name,
    super.email,
    super.phone,
    super.imageUrl,
    required super.id,
    required super.role,
  });

  factory UserDataModel.fromJson(Map<String, dynamic> json) {
    return UserDataModel(
      id: json['id'] as String,
      role: UserRole.values.byName(json['user_metadata']['role'] as String),
      name: json['user_metadata']['name'] as String?,
      email: json['user_metadata']['email'] as String?,
      phone: json['user_metadata']['phone'] as String?,
      imageUrl: json['user_metadata']['imagee_url'] as String?,
    );
  }
}
