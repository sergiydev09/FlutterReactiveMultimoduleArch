/// Represents the application environment.
enum Environment {
  /// Mock environment for local development with fake data.
  mock,

  /// Pre-production / staging environment.
  pre,

  /// Production environment.
  pro,
}

/// Holds environment-specific configuration values.
class EnvironmentConfig {
  const EnvironmentConfig._({
    required this.environment,
    required this.baseUrl,
    required this.connectTimeout,
    required this.receiveTimeout,
    required this.enableLogging,
  });

  /// Creates the configuration for the given [environment].
  factory EnvironmentConfig.fromEnvironment(Environment environment) {
    return switch (environment) {
      Environment.mock => const EnvironmentConfig._(
        environment: Environment.mock,
        baseUrl: 'http://localhost:8080/api/v1',
        connectTimeout: Duration(seconds: 30),
        receiveTimeout: Duration(seconds: 30),
        enableLogging: true,
      ),
      Environment.pre => const EnvironmentConfig._(
        environment: Environment.pre,
        baseUrl: 'https://pre-api.banking-app.com/api/v1',
        connectTimeout: Duration(seconds: 15),
        receiveTimeout: Duration(seconds: 15),
        enableLogging: true,
      ),
      Environment.pro => const EnvironmentConfig._(
        environment: Environment.pro,
        baseUrl: 'https://api.banking-app.com/api/v1',
        connectTimeout: Duration(seconds: 10),
        receiveTimeout: Duration(seconds: 10),
        enableLogging: false,
      ),
    };
  }

  /// The current environment.
  final Environment environment;

  /// Base URL for all API calls.
  final String baseUrl;

  /// Maximum duration to wait for a connection.
  final Duration connectTimeout;

  /// Maximum duration to wait for a response.
  final Duration receiveTimeout;

  /// Whether network logging is enabled.
  final bool enableLogging;

  /// Whether the app is running in production.
  bool get isProduction => environment == Environment.pro;

  /// Whether the app is running with mock data.
  bool get isMock => environment == Environment.mock;
}
