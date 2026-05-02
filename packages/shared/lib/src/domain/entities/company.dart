import 'package:shared/src/domain/entities/company_config.dart';
import 'package:shared/src/domain/entities/company_integration.dart';

class Company {
  const Company({
    required this.id,
    required this.name,
    this.businessHandle,
    this.logoUrl,
    this.cac,
    this.address,
    this.placeId,
    this.contactPhone,
    this.config,
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
  final String? contactPhone;
  final CompanyConfig? config;
  final List<CompanyIntegration>? integrations;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Company copyWith({
    String? id,
    String? name,
    String? businessHandle,
    String? logoUrl,
    String? cac,
    String? address,
    String? placeId,
    String? contactPhone,
    CompanyConfig? config,
    List<CompanyIntegration>? integrations,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Company(
      id: id ?? this.id,
      name: name ?? this.name,
      businessHandle: businessHandle ?? this.businessHandle,
      logoUrl: logoUrl ?? this.logoUrl,
      cac: cac ?? this.cac,
      address: address ?? this.address,
      placeId: placeId ?? this.placeId,
      contactPhone: contactPhone ?? this.contactPhone,
      config: config ?? this.config,
      integrations: integrations ?? this.integrations,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
