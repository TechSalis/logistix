import 'package:url_launcher/url_launcher.dart' as ul;

class LogistixLauncher {
  static Future<bool> Function(Uri url) canLaunchUrl = ul.canLaunchUrl;
  static Future<void> Function(Uri url, {ul.LaunchMode mode}) launchUrl =
      ul.launchUrl;

  static Future<void> openMap(double lat, double lng) async {
    final googleAppUrl = Uri.parse('google.navigation:q=$lat,$lng');
    final webUrl = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );

    if (await canLaunchUrl(googleAppUrl)) {
      return launchInBrowser(googleAppUrl.toString());
    }

    if (await canLaunchUrl(webUrl)) {
      return launchInBrowser(webUrl.toString());
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
    ul.LaunchMode mode = ul.LaunchMode.externalApplication,
  }) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: mode);
    }
  }
}
