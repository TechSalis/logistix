import 'package:dispatcher/generated/assets.gen.dart';
import 'package:flutter/widgets.dart';
import 'package:shared/shared.dart';

/// Centralised mapping from [ChatPlatform] to display name and icon widget.
///
/// Use these everywhere instead of duplicating switch-cases:
///   • [ChatPlatform.displayName]  → human-readable label
///   • [ChatPlatform.icon()]        → SVG icon widget (sized by caller)
extension ChatPlatformX on ChatPlatform {
  /// Human-readable label, e.g. "WhatsApp", "Facebook".
  String get displayName {
    switch (this) {
      case ChatPlatform.WHATSAPP:
        return 'WhatsApp';
      case ChatPlatform.FACEBOOK:
        return 'Facebook';
      case ChatPlatform.INSTAGRAM:
        return 'Instagram';
      case ChatPlatform.TIKTOK:
        return 'TikTok';
    }
  }

  /// Branded SVG icon. Optionally pass [size] (default 14).
  Widget icon({double size = 14, Color? color}) {
    final colorFilter =
        color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null;
    switch (this) {
      case ChatPlatform.WHATSAPP:
        return DispatcherAssets.icons.socials.whatsapp.svg(
          width: size,
          height: size,
          colorFilter: colorFilter,
        );
      case ChatPlatform.FACEBOOK:
        return DispatcherAssets.icons.socials.facebook.svg(
          width: size,
          height: size,
          colorFilter: colorFilter,
        );
      case ChatPlatform.INSTAGRAM:
        return DispatcherAssets.icons.socials.instagram.svg(
          width: size,
          height: size,
          colorFilter: colorFilter,
        );
      case ChatPlatform.TIKTOK:
        return DispatcherAssets.icons.socials.tiktok.svg(
          width: size,
          height: size,
          colorFilter: colorFilter,
        );
    }
  }
}
