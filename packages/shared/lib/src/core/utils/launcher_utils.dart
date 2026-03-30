import 'package:url_launcher/url_launcher.dart';

class LauncherUtils {
  static Future<void> openMap(double lat, double lng) async {
    final googleAppUrl = Uri.parse('google.navigation:q=$lat,$lng');
    final webUrl = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );

    if (await canLaunchUrl(googleAppUrl)) {
      await launchUrl(googleAppUrl, mode: LaunchMode.externalApplication);
      return;
    }

    // Fallback to web URL in an external browser
    if (await canLaunchUrl(webUrl)) {
      await launchUrl(webUrl);
    }
  }

  static Future<void> callNumber(String phone) async {
    final telUrl = Uri.parse('tel:${phone.replaceAll(' ', '')}');
    if (await canLaunchUrl(telUrl)) {
      await launchUrl(telUrl);
    }
  }

  /// Generic external launcher for any URL (e.g. tracking links, websites)
  static Future<void> launchInBrowser(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
