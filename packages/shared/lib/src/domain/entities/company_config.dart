import 'package:shared/src/domain/entities/billing_tier.dart';

class CompanyConfig {
  const CompanyConfig({
    required this.id,
    required this.companyId,
    required this.tier,
  });

  final String id;
  final String companyId;
  final BillingTier tier;

  CompanyConfig copyWith({
    String? id,
    String? companyId,
    BillingTier? tier,
  }) {
    return CompanyConfig(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      tier: tier ?? this.tier,
    );
  }
}
