abstract class EnvConfig {
  static const String _host = String.fromEnvironment('HOST');

  static String get apiUrl =>
      const String.fromEnvironment('API_URL', defaultValue: 'http://$_host');

  static String get refreshUrl => const String.fromEnvironment('REFRESH_URL');

  static String get graphqlUrl => const String.fromEnvironment(
        'GRAPHQL_URL',
        defaultValue: 'http://$_host/graphql',
      );

  static String get wsUrl => const String.fromEnvironment(
        'WS_URL',
        defaultValue: 'ws://$_host/graphql/ws',
      );

  static String get sentryDsn => const String.fromEnvironment('SENTRY_DSN');

  static String get contactSupportUrl =>
      const String.fromEnvironment('CONTACT_SUPPORT_URL');

  static String get environment => const String.fromEnvironment('ENVIRONMENT');

  static String get trackingLink =>
      const String.fromEnvironment('TRACKING_LINK');

  static bool get isDevelopment => environment == 'development';

  static bool get isProduction => environment == 'production';
}
