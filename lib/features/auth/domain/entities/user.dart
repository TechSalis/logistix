import 'package:logistix/features/auth/domain/entities/user_data.dart';

enum UserRole { customer, rider, company }

class User {
  final String id;
  final UserRole role;
  final bool isAnonymous;
  final UserData data;

  const User({
    required this.id,
    required this.isAnonymous,
    required this.role,
    required this.data,
  });
}
