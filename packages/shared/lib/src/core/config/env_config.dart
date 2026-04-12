/// Generic Environment Configuration using --dart-define values
class EnvConfig {
  String get apiUrl => const String.fromEnvironment('API_URL');
  String get refreshUrl => const String.fromEnvironment('REFRESH_URL');
  String get graphqlUrl => const String.fromEnvironment('GRAPHQL_URL');
  String get wsUrl => const String.fromEnvironment('WS_URL');
  String get sentryDsn => const String.fromEnvironment('SENTRY_DSN');
  String get contactSupportUrl =>
      const String.fromEnvironment('CONTACT_SUPPORT_URL');
  String get environment => const String.fromEnvironment('ENVIRONMENT');
  String get trackingLink => const String.fromEnvironment('TRACKING_LINK');
  String get clientKey => const String.fromEnvironment('CLIENT_KEY');
  String get appName => const String.fromEnvironment('APP_NAME');
  
  bool get isSingleTenant =>
      const String.fromEnvironment('SYSTEM_MODE') == 'SINGLE_TENANT';

  bool get isDevelopment => environment == 'development';
  bool get isProduction => environment == 'production';

  /// Standard singleton instance for the current environment.
  /// Set this during app initialization.
  static late EnvConfig instance;
}
