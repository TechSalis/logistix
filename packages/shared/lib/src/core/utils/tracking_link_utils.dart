import 'package:shared/shared.dart';

class TrackingLinkUtils {
  /// Generates a secure tracking link for an order.
  static String generateLink({
    required String trackingNumber,
    String? trackingCode,
  }) {
    final baseUrl = EnvConfig.instance.trackingLink;
    final url = '$baseUrl/${trackingNumber.toUpperCase()}';
    
    if (trackingCode != null && trackingCode.isNotEmpty) {
      return '$url?code=$trackingCode';
    }
    
    return url;
  }
}
