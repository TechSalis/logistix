import 'package:shared/shared.dart';

class LoginResponse {
  const LoginResponse({
    required this.user,
    this.riderProfile,
    this.companyProfile,
  });

  final User user;
  final Rider? riderProfile;
  final Company? companyProfile;
}
