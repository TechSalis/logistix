import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shared/src/domain/entities/company.dart';
import 'company_integration_dto.dart';

part 'company_dto.freezed.dart';
part 'company_dto.g.dart';

@freezed
abstract class CompanyDto with _$CompanyDto {
  const factory CompanyDto({
    required String id,
    required String name,
    String? businessHandle,
    String? logoUrl,
    String? cac,
    String? address,
    List<CompanyIntegrationDto>? integrations,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _CompanyDto;

  factory CompanyDto.fromEntity(Company company) => CompanyDto(
    id: company.id,
    name: company.name,
    businessHandle: company.businessHandle,
    logoUrl: company.logoUrl,
    cac: company.cac,
    address: company.address,
    integrations: company.integrations?.map((e) => CompanyIntegrationDto.fromEntity(e)).toList(),
    createdAt: company.createdAt,
    updatedAt: company.updatedAt,
  );

  const CompanyDto._();

  factory CompanyDto.fromJson(Map<String, dynamic> json) =>
      _$CompanyDtoFromJson(json);

  Company toEntity() => Company(
    id: id,
    name: name,
    businessHandle: businessHandle,
    logoUrl: logoUrl,
    cac: cac,
    address: address,
    integrations: integrations?.map((e) => e.toEntity()).toList(),
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}
