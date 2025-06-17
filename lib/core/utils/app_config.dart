
class EnvConfig {
  final String apiUrl;
  final String mapboxToken;
  // final String env;

  EnvConfig._internal({
    required this.apiUrl,
    required this.mapboxToken,
    // required this.env,
  });

  static EnvConfig? _instance;
  static EnvConfig get instance => _instance!;

  static void extract(Map<String, String> variables) {
    _instance = EnvConfig._internal(
      apiUrl: variables['API_URL'] ?? '',
      mapboxToken: variables['MAPBOX_PUBLIC_TOKEN'] ?? '',
      // env: variables['ENV'] ?? 'dev',
    );
  }
}
