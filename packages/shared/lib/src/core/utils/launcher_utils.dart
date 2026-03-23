import 'dart:io';
import 'package:url_launcher/url_launcher.dart';

class LauncherUtils {
  static Future<void> openMap(double lat, double lng) async {
    final googleUrl = Uri.parse('google.navigation:q=$lat,$lng');
    final appleUrl = Uri.parse('https://maps.apple.com/?q=$lat,$lng');

    if (Platform.isAndroid) {
      if (await canLaunchUrl(googleUrl)) {
        await launchUrl(googleUrl);
      } else {
        throw Exception('Could not open Google Maps');
      }
    } else if (Platform.isIOS) {
      if (await canLaunchUrl(appleUrl)) {
        await launchUrl(appleUrl);
      } else {
        throw Exception('Could not open Apple Maps');
      }
    }
  }

  static Future<void> callNumber(String phone) async {
    final telUrl = Uri.parse('tel:$phone');
    if (await canLaunchUrl(telUrl)) {
      await launchUrl(telUrl);
    } else {
      throw Exception('Could not launch dialer');
    }
  }
}
