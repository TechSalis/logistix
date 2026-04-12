class SignUpRequest {
  const SignUpRequest({
    required this.email,
    required this.password,
    required this.name,
  });

  factory SignUpRequest.fromJson(Map<String, dynamic> json) {
    return SignUpRequest(
      email: json['email'] as String,
      password: json['password'] as String,
      name: json['fullName'] as String,
    );
  }

  final String email;
  final String password;
  final String name;

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'fullName': name,
    };
  }
}
