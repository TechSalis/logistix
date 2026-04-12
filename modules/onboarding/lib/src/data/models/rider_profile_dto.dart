class RiderProfileDto {
  const RiderProfileDto({
    required this.phoneNumber,
    required this.registrationNumber,
    this.companyId,
  });

  factory RiderProfileDto.fromJson(Map<String, dynamic> json) {
    return RiderProfileDto(
      phoneNumber: json['phoneNumber'] as String,
      registrationNumber: json['registrationNumber'] as String,
      companyId: json['companyId'] as String?,
    );
  }

  final String phoneNumber;
  final String registrationNumber;
  final String? companyId;

  Map<String, dynamic> toJson() {
    return {
      'phoneNumber': phoneNumber,
      'registrationNumber': registrationNumber,
      if (companyId != null) 'companyId': companyId,
    };
  }
}
