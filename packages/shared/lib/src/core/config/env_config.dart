abstract class EnvConfig {
  String get apiUrl;
  String get graphqlUrl;
  String get wsUrl;
  String get sentryDsn;
  String get contactSupportUrl;
  String get environment;
  String get trackingLink;
  String get clientKey;
  bool get isSingleTenant;

  bool get isDevelopment => environment == 'development';
  bool get isProduction => environment == 'production';

  /// Standard singleton instance for the current environment.
  /// Set this during app initialization.
  static late EnvConfig instance;
}

class LocalEnvConfig extends EnvConfig {
  final String host = '0.0.0.0';

  final int port = 4000;

  @override
  String get apiUrl => 'http://$host:$port/v1';

  @override
  String get graphqlUrl => 'http://$host:$port/v1/graphql';

  @override
  String get wsUrl => 'ws://$host:$port/v1/graphql/ws';

  @override
  String get sentryDsn => '';

  @override
  String get contactSupportUrl => '';

  @override
  String get environment => 'development';

  @override
  String get trackingLink => 'http://localhost:5173/track';

  @override
  String get clientKey => 'Lgx_7f8d2b1c9a0e4f5a6b7c8d9e0f1a2b3c';

  @override
  bool get isSingleTenant => false;
}

class ProductionEnvConfig extends EnvConfig {
  @override
  String get apiUrl => const String.fromEnvironment('API_URL');

  @override
  String get graphqlUrl => const String.fromEnvironment('GRAPHQL_URL');

  @override
  String get wsUrl => const String.fromEnvironment('WS_URL');

  @override
  String get sentryDsn => const String.fromEnvironment('SENTRY_DSN');

  @override
  String get contactSupportUrl =>
      const String.fromEnvironment('CONTACT_SUPPORT_URL');

  @override
  String get environment => const String.fromEnvironment('ENVIRONMENT');

  @override
  String get trackingLink => const String.fromEnvironment('TRACKING_LINK');

  @override
  String get clientKey => const String.fromEnvironment('CLIENT_KEY');

  @override
  bool get isSingleTenant => const String.fromEnvironment('SYSTEM_MODE') == 'SINGLE';
}
