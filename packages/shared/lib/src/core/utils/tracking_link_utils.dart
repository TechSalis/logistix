import 'package:shared/src/core/config/env_config.dart';

class LogistixTracking {
  static String generateLink({
    required String trackingNumber,
    required String trackingCode,
  }) {
    final base = EnvConfig.instance.trackingLink;
    return '$base/track/$trackingNumber?code=$trackingCode';
  }
}
