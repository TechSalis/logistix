import 'package:logistix/features/auth/domain/entities/user_data.dart';

class UserDataModel extends UserData {
  const UserDataModel({
    super.name,
    super.email,
    super.phone,
    super.imageUrl,
    required super.id,
  });

  factory UserDataModel.fromJson(Map<String, dynamic> json) {
    return UserDataModel(
      id: json['id'] as String,
      name: json['user_metadata']['name'] as String?,
      email: json['user_metadata']['email'] as String?,
      phone: json['user_metadata']['phone'] as String?,
      imageUrl: json['user_metadata']['imageUrl'] as String?,
    );
  }
}
