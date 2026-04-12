import 'package:url_launcher/url_launcher.dart';

class LogistixLauncher {
  static Future<void> openMap(double lat, double lng) async {
    final googleAppUrl = Uri.parse('google.navigation:q=$lat,$lng');
    final webUrl = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );

    if (await canLaunchUrl(googleAppUrl)) {
      await launchInBrowser(googleAppUrl.toString());
      return;
    }

    if (await canLaunchUrl(webUrl)) {
      await launchInBrowser(webUrl.toString());
    }
  }

  static Future<void> callNumber(String phone) async {
    final telUrl = Uri.parse('tel:${phone.replaceAll(' ', '')}');
    if (await canLaunchUrl(telUrl)) {
      await launchInBrowser(telUrl.toString());
    }
  }

  static Future<void> launchInBrowser(
    String url, {
    LaunchMode mode = LaunchMode.externalApplication,
  }) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: mode);
    }
  }
}
