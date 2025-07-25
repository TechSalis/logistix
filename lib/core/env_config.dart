// ignore_for_file: non_constant_identifier_names
import 'package:flutter/foundation.dart';

///Ensure the [EnvConfig.extract] function is called before the class is used
class EnvConfig {
  final String ENV;
  final String apiUrl;
  final String googleApiKey;
  final String supabaseAnonKey;
  final String mapboxApiKey;

  EnvConfig._internal({
    required this.ENV,
    required this.apiUrl,
    required this.googleApiKey,
    required this.supabaseAnonKey,
    required this.mapboxApiKey,
  });

  static EnvConfig? _instance;

  static EnvConfig get instance => _instance!;

  bool get isDev => kDebugMode || ENV == 'DEV';

  ///Ensure this function is called before the class is used
  static void extract(Map<String, String> variables) {
    _instance = EnvConfig._internal(
      ENV: variables['ENV']!,
      apiUrl: variables['API_URL']!,
      mapboxApiKey: variables['MAPBOX_API_KEY']!,
      googleApiKey: variables['GOOGLE_MAP_API_KEY']!,
      supabaseAnonKey: variables['SUPABASE_ANON_KEY']!,
    );
  }
}
