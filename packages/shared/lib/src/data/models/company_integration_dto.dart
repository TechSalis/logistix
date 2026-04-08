import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shared/src/domain/entities/company_integration.dart';
import 'package:shared/src/domain/entities/platform.dart';

part 'company_integration_dto.freezed.dart';
part 'company_integration_dto.g.dart';

@freezed
abstract class CompanyIntegrationDto with _$CompanyIntegrationDto {
  const factory CompanyIntegrationDto({
    required String id,
    required String platform,
    required String platformId,
    required bool isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _CompanyIntegrationDto;

  factory CompanyIntegrationDto.fromEntity(CompanyIntegration entity) => CompanyIntegrationDto(
    id: entity.id,
    platform: entity.platform.name.toUpperCase(),
    platformId: entity.platformId,
    isActive: entity.isActive,
    createdAt: entity.createdAt,
    updatedAt: entity.updatedAt,
  );

  const CompanyIntegrationDto._();

  factory CompanyIntegrationDto.fromJson(Map<String, dynamic> json) =>
      _$CompanyIntegrationDtoFromJson(json);

  CompanyIntegration toEntity() => CompanyIntegration(
    id: id,
    platform: Platform.fromString(platform),
    platformId: platformId,
    isActive: isActive,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}
