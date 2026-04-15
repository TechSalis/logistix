import 'package:shared/src/core/config/env_config.dart';

class LogistixTracking {
  static String generateLink(String trackingNumber, {String? trackingCode}) {
    final base = EnvConfig.instance.trackingLink;
    var link = '$base/track/$trackingNumber';
    if (trackingCode != null) link += '?code=$trackingCode';
    return link;
  }
}
