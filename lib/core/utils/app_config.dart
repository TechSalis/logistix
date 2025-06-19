
class EnvConfig {
  final String apiUrl;
  final String mapBoxApiUrl;
  final String mapboxToken;

  EnvConfig._internal({
    required this.apiUrl,
    required this.mapBoxApiUrl,
    required this.mapboxToken,
  });

  static EnvConfig? _instance;
  static EnvConfig get instance => _instance!;

  static void extract(Map<String, String> variables) {
    _instance = EnvConfig._internal(
      apiUrl: variables['API_URL'] ?? '',
      mapBoxApiUrl: variables['MAPBOX_API_URL'] ?? '',
      mapboxToken: variables['MAPBOX_PUBLIC_TOKEN'] ?? '',
      // env: variables['ENV'] ?? 'dev',
    );
  }
}
