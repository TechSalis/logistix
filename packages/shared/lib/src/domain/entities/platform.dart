enum Platform {
  whatsapp,
  instagram,
  facebook,
  tiktok,
  custom;

  static Platform fromString(String value) {
    return Platform.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => Platform.custom,
    );
  }
}
