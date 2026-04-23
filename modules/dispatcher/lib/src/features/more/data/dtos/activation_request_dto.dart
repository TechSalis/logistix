import 'package:shared/shared.dart';

class ActivationRequestDto {
  const ActivationRequestDto({
    required this.email,
    required this.name,
    required this.phone,
    required this.platform,
    this.useDedicatedNumber = false,
  });

  factory ActivationRequestDto.fromJson(Map<String, dynamic> json) {
    return ActivationRequestDto(
      email: json['email'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      platform: ChatPlatform.fromString(json['platform'] as String),
      useDedicatedNumber: json['useDedicatedNumber'] as bool? ?? false,
    );
  }

  final String email;
  final String name;
  final String phone;
  final ChatPlatform platform;
  final bool useDedicatedNumber;

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'name': name,
      'phone': phone,
      'platform': platform.name,
      'useDedicatedNumber': useDedicatedNumber,
    };
  }
}
