import 'package:freezed_annotation/freezed_annotation.dart';
import 'platform.dart';

part 'company_integration.freezed.dart';

@freezed
abstract class CompanyIntegration with _$CompanyIntegration {
  const factory CompanyIntegration({
    required String id,
    required Platform platform,
    required String platformId,
    required bool isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _CompanyIntegration;
}
