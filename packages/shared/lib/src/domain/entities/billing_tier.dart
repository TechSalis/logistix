enum BillingTier {
  free,
  starter,
  professional;

  static BillingTier fromString(String value) {
    return BillingTier.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => BillingTier.free,
    );
  }
}
