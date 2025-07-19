import 'package:logistix/features/auth/domain/entities/user_session.dart';

class UserData {
  final String id;
  final UserRole role;
  final String? name;
  final String? email;
  final String? phone;
  final String? imageUrl;

  const UserData({
    required this.id,
    required this.role,
    this.name,
    this.email,
    this.phone,
    this.imageUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role.name,
      'name': name,
      'email': email,
      'phone': phone,
      'imagee_url': imageUrl,
    };
  }
}
