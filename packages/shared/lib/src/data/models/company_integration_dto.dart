import 'package:flutter/foundation.dart';
import 'package:shared/src/domain/entities/company_integration.dart';

@immutable
class CompanyIntegrationDto {
  const CompanyIntegrationDto({
    required this.id,
    required this.platform,
    required this.platformId,
    required this.isActive,
    this.useDedicatedNumber = false,
    this.createdAt,
    this.updatedAt,
  });

  factory CompanyIntegrationDto.fromEntity(CompanyIntegration entity) =>
      CompanyIntegrationDto(
        id: entity.id,
        platform: entity.platform.name,
        platformId: entity.platformId,
        isActive: entity.isActive,
        useDedicatedNumber: entity.useDedicatedNumber,
        createdAt: entity.createdAt,
        updatedAt: entity.updatedAt,
      );

  factory CompanyIntegrationDto.fromJson(Map<String, dynamic> json) {
    return CompanyIntegrationDto(
      id: json['id'] as String,
      platform: json['platform'] as String,
      platformId: json['platformId'] as String,
      isActive: json['isActive'] as bool? ?? true,
      useDedicatedNumber: json['useDedicatedNumber'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  final String id;
  final String platform;
  final String platformId;
  final bool isActive;
  final bool useDedicatedNumber;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'platform': platform,
      'platformId': platformId,
      'isActive': isActive,
      'useDedicatedNumber': useDedicatedNumber,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  CompanyIntegration toEntity() => CompanyIntegration(
        id: id,
        platform: ChatPlatform.fromString(platform),
        platformId: platformId,
        isActive: isActive,
        useDedicatedNumber: useDedicatedNumber,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompanyIntegrationDto &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          platform == other.platform &&
          platformId == other.platformId &&
          isActive == other.isActive;

  @override
  int get hashCode =>
      id.hashCode ^ platform.hashCode ^ platformId.hashCode ^ isActive.hashCode;
}
