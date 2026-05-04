enum BillingTier {
  free,
  starter,
  professional;

  String get label {
    switch (this) {
      case BillingTier.free:
        return 'Free';
      case BillingTier.starter:
        return 'Starter';
      case BillingTier.professional:
        return 'Professional';
    }
  }

  static BillingTier fromString(String value) {
    return BillingTier.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => BillingTier.free,
    );
  }
}
