class DispatcherProfileDto {
  const DispatcherProfileDto({
    this.companyName,
    this.phoneNumber,
    this.address,
    this.placeId,
    this.cac,
  });

  factory DispatcherProfileDto.fromJson(Map<String, dynamic> json) {
    return DispatcherProfileDto(
      companyName: json['companyName'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      address: json['address'] as String?,
      placeId: json['placeId'] as String?,
      cac: json['cac'] as String?,
    );
  }

  final String? companyName;
  final String? phoneNumber;
  final String? address;
  final String? placeId;
  final String? cac;

  Map<String, dynamic> toJson() {
    return {
      if (companyName != null) 'companyName': companyName,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
      if (address != null) 'address': address,
      if (placeId != null) 'placeId': placeId,
      if (cac != null) 'cac': cac,
    };
  }
}
