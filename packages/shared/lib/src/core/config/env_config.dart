abstract class EnvConfig {
  String get host;
  int get port;
  String get apiUrl;
  String get graphqlUrl;
  String get wsUrl;
  String get sentryDsn;
  String get contactSupportUrl;
  String get environment;
  String get trackingLink;

  bool get isDevelopment => environment == 'development';
  bool get isProduction => environment == 'production';

  /// Standard singleton instance for the current environment.
  /// Set this during app initialization.
  static late EnvConfig instance;
}

class LocalEnvConfig extends EnvConfig {
  @override
  final String host = '0.0.0.0';

  @override
  final int port = 4000;

  @override
  String get apiUrl => 'http://$host:$port';

  @override
  String get graphqlUrl => 'http://$host:$port/graphql';

  @override
  String get wsUrl => 'ws://$host:$port/graphql/ws';

  @override
  String get sentryDsn => '';

  @override
  String get contactSupportUrl => '';

  @override
  String get environment => 'development';

  @override
  String get trackingLink => 'http://$host:$port/track';
}

class ProductionEnvConfig extends EnvConfig {
  @override
  String get host => const String.fromEnvironment('HOST');

  @override
  int get port => const int.fromEnvironment('PORT', defaultValue: 80);

  @override
  String get apiUrl => const String.fromEnvironment(
        'API_URL',
        defaultValue: 'https://api.logistix.com',
      );

  @override
  String get graphqlUrl => const String.fromEnvironment(
        'GRAPHQL_URL',
        defaultValue: 'https://api.logistix.com/graphql',
      );

  @override
  String get wsUrl => const String.fromEnvironment(
        'WS_URL',
        defaultValue: 'wss://api.logistix.com/graphql/ws',
      );

  @override
  String get sentryDsn => const String.fromEnvironment('SENTRY_DSN');

  @override
  String get contactSupportUrl =>
      const String.fromEnvironment('CONTACT_SUPPORT_URL');

  @override
  String get environment =>
      const String.fromEnvironment('ENVIRONMENT', defaultValue: 'production');

  @override
  String get trackingLink =>
      const String.fromEnvironment('TRACKING_LINK', defaultValue: 'https://shipment.logistix.com');
}
