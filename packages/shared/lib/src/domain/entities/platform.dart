import 'package:freezed_annotation/freezed_annotation.dart';

enum Platform {
  @JsonValue('WHATSAPP')
  whatsapp,
  @JsonValue('INSTAGRAM')
  instagram,
  @JsonValue('FACEBOOK')
  facebook,
  @JsonValue('TIKTOK')
  tiktok,
  @JsonValue('CUSTOM')
  custom;

  static Platform fromString(String value) {
    return Platform.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => Platform.custom,
    );
  }
}
