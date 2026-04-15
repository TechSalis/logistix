// ignore_for_file: constant_identifier_names
enum ChatPlatform {
  WHATSAPP,
  INSTAGRAM,
  FACEBOOK,
  TIKTOK;

  static ChatPlatform fromString(String value) {
    return ChatPlatform.values.firstWhere(
      (e) => e.name == value.toUpperCase(),
      orElse: () => ChatPlatform.WHATSAPP,
    );
  }
}

class CompanyIntegration {
  const CompanyIntegration({
    required this.id,
    required this.platform,
    required this.platformId,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final ChatPlatform platform;
  final String platformId;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
}
