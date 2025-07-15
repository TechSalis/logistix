import 'package:logistix/features/auth/domain/entities/user_data.dart';

enum UserRole { customer, rider, company }

class AuthUser {
  final String id;
  final UserRole role;
  final bool isAnonymous;
  final UserData data;

  const AuthUser({
    required this.id,
    required this.isAnonymous,
    required this.role,
    required this.data,
  });
}

