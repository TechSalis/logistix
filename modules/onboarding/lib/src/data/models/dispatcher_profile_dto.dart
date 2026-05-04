import 'package:shared/shared.dart';

class DispatcherProfileDto {
  const DispatcherProfileDto({
    this.companyName,
    this.phoneNumber,
    this.address,
    this.placeId,
    this.cac,
    this.workingHours,
  });

  factory DispatcherProfileDto.fromJson(Map<String, dynamic> json) {
    return DispatcherProfileDto(
      companyName: json['companyName'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      address: json['address'] as String?,
      placeId: json['placeId'] as String?,
      cac: json['cac'] as String?,
      workingHours: json['workingHours'] != null ? WorkingHours.fromJson(json['workingHours'] as Map<String, dynamic>) : null,
    );
  }

  final String? companyName;
  final String? phoneNumber;
  final String? address;
  final String? placeId;
  final String? cac;
  final WorkingHours? workingHours;

  Map<String, dynamic> toJson() {
    return {
      if (companyName != null) 'companyName': companyName,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
      if (address != null) 'address': address,
      if (placeId != null) 'placeId': placeId,
      if (cac != null) 'cac': cac,
      if (workingHours != null) 'workingHours': workingHours!.toJson(),
    };
  }
}
