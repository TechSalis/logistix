enum SubscriptionTier {
  free,
  starter,
  professional;

  String get label {
    switch (this) {
      case SubscriptionTier.free:
        return 'Free';
      case SubscriptionTier.starter:
        return 'Starter';
      case SubscriptionTier.professional:
        return 'Professional';
    }
  }

  static SubscriptionTier fromString(String value) {
    return SubscriptionTier.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => SubscriptionTier.free,
    );
  }
}
