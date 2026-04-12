class ResetPasswordRequest {
  const ResetPasswordRequest({
    required this.email,
    required this.newPassword,
  });

  factory ResetPasswordRequest.fromJson(Map<String, dynamic> json) {
    return ResetPasswordRequest(
      email: json['email'] as String,
      newPassword: json['newPassword'] as String,
    );
  }

  final String email;
  final String newPassword;

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': newPassword,
    };
  }
}
