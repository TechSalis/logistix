import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shared/src/domain/entities/company.dart';

part 'company_dto.freezed.dart';
part 'company_dto.g.dart';

@freezed
class CompanyDto with _$CompanyDto {
  const factory CompanyDto({
    required String id,
    required String name,
    String? logoUrl,
    String? cac,
    String? address,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _CompanyDto;

  factory CompanyDto.fromEntity(Company company) => CompanyDto(
    id: company.id,
    name: company.name,
    logoUrl: company.logoUrl,
    cac: company.cac,
    address: company.address,
    createdAt: company.createdAt,
    updatedAt: company.updatedAt,
  );

  const CompanyDto._();

  factory CompanyDto.fromJson(Map<String, dynamic> json) =>
      _$CompanyDtoFromJson(json);

  Company toEntity() => Company(
    id: id,
    name: name,
    logoUrl: logoUrl,
    cac: cac,
    address: address,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}
