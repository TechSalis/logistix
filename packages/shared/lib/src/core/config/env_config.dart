abstract class EnvConfig {
  static String get graphqlUrl => const String.fromEnvironment('GRAPHQL_URL');

  static String get refreshUrl => const String.fromEnvironment('REFRESH_URL');

  static String get wsUrl => const String.fromEnvironment('WS_URL');

  static String get sentryDsn => const String.fromEnvironment('SENTRY_DSN');

  static String get contactSupportUrl =>
      const String.fromEnvironment('CONTACT_SUPPORT_URL');

  static String get environment => const String.fromEnvironment('ENVIRONMENT');

  static bool get isDevelopment => environment == 'development';

  static bool get isProduction => environment == 'production';
}
