import 'package:flutter/foundation.dart';
import 'package:shared/src/domain/entities/company_config.dart';
import 'package:shared/src/domain/entities/subscription_tier.dart';

@immutable
class CompanyConfigDto {
  const CompanyConfigDto({
    required this.id,
    required this.companyId,
    required this.tier,
  });

  factory CompanyConfigDto.fromEntity(CompanyConfig entity) => CompanyConfigDto(
        id: entity.id,
        companyId: entity.companyId,
        tier: entity.tier,
      );

  factory CompanyConfigDto.fromJson(Map<String, dynamic> json) {
    return CompanyConfigDto(
      id: json['id'] as String,
      companyId: json['companyId'] as String,
      tier: SubscriptionTier.fromString(json['tier'] as String),
    );
  }

  final String id;
  final String companyId;
  final SubscriptionTier tier;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'companyId': companyId,
      'tier': tier.name,
    };
  }

  CompanyConfig toEntity() => CompanyConfig(
        id: id,
        companyId: companyId,
        tier: tier,
      );
}
