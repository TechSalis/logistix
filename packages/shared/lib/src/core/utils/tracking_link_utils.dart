import 'package:shared/src/core/config/env_config.dart';

class LogistixTracking {
  static String generateLink(String trackingNumber, {String? trackingCode}) {
    var base = EnvConfig.instance.trackingLink;
    if (base.endsWith('/')) {
      base = base.substring(0, base.length - 1);
    }

    var link = '$base/$trackingNumber';
    if (trackingCode != null && trackingCode.isNotEmpty) {
      link += '?code=$trackingCode';
    }

    return link;
  }
}
