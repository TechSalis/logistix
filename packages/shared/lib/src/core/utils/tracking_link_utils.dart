import 'package:shared/src/core/config/project_config.dart';

class LogistixTracking {
  static String generateLink(String trackingNumber, {String? trackingPin}) {
    var base = ProjectConfig.trackingLink;
    if (base.endsWith('/')) {
      base = base.substring(0, base.length - 1);
    }

    var link = '$base/$trackingNumber';
    if (trackingPin != null && trackingPin.isNotEmpty) {
      link += '?pin=$trackingPin';
    }

    return link;
  }
}
