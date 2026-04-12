class VerifyOtpRequest {
  const VerifyOtpRequest({
    required this.email,
    required this.otp,
  });

  factory VerifyOtpRequest.fromJson(Map<String, dynamic> json) {
    return VerifyOtpRequest(
      email: json['email'] as String,
      otp: json['otp'] as String,
    );
  }

  final String email;
  final String otp;

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'otp': otp,
    };
  }
}
