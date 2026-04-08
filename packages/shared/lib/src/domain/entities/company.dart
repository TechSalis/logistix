import 'package:freezed_annotation/freezed_annotation.dart';
import 'company_integration.dart';

part 'company.freezed.dart';

@freezed
abstract class Company with _$Company {
  const factory Company({
    required String id,
    required String name,
    String? businessHandle,
    String? logoUrl,
    String? cac,
    String? address,
    List<CompanyIntegration>? integrations,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Company;
}
