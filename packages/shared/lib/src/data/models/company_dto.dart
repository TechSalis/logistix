import 'package:shared/src/data/models/company_integration_dto.dart';
import 'package:shared/src/domain/entities/company.dart';

class CompanyDto {
  const CompanyDto({
    required this.id,
    required this.name,
    this.businessHandle,
    this.logoUrl,
    this.cac,
    this.address,
    this.placeId,
    this.integrations,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String? businessHandle;
  final String? logoUrl;
  final String? cac;
  final String? address;
  final String? placeId;
  final List<CompanyIntegrationDto>? integrations;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory CompanyDto.fromEntity(Company company) => CompanyDto(
        id: company.id,
        name: company.name,
        businessHandle: company.businessHandle,
        logoUrl: company.logoUrl,
        cac: company.cac,
        address: company.address,
        placeId: company.placeId,
        integrations: company.integrations
            ?.map(CompanyIntegrationDto.fromEntity)
            .toList(),
        createdAt: company.createdAt,
        updatedAt: company.updatedAt,
      );

  factory CompanyDto.fromJson(Map<String, dynamic> json) {
    return CompanyDto(
      id: json['id'] as String,
      name: json['name'] as String,
      businessHandle: json['businessHandle'] as String?,
      logoUrl: json['logoUrl'] as String?,
      cac: json['cac'] as String?,
      address: json['address'] as String?,
      placeId: json['placeId'] as String?,
      integrations: (json['integrations'] as List<dynamic>?)
          ?.map((e) => CompanyIntegrationDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (businessHandle != null) 'businessHandle': businessHandle,
      if (logoUrl != null) 'logoUrl': logoUrl,
      if (cac != null) 'cac': cac,
      if (address != null) 'address': address,
      if (placeId != null) 'placeId': placeId,
      if (integrations != null)
        'integrations': integrations!.map((e) => e.toJson()).toList(),
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  Company toEntity() => Company(
        id: id,
        name: name,
        businessHandle: businessHandle,
        logoUrl: logoUrl,
        cac: cac,
        address: address,
        placeId: placeId,
        integrations: integrations?.map((e) => e.toEntity()).toList(),
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompanyDto &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          businessHandle == other.businessHandle;

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ businessHandle.hashCode;
}
