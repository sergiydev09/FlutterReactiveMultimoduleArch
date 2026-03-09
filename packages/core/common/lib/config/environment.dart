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
    required this.certificatePinHashes,
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
        // No pinning for mock — traffic is local.
        certificatePinHashes: [],
      ),
      Environment.pre => const EnvironmentConfig._(
        environment: Environment.pre,
        baseUrl: 'https://pre-api.banking-app.com/api/v1',
        connectTimeout: Duration(seconds: 15),
        receiveTimeout: Duration(seconds: 15),
        enableLogging: true,
        // SHA-256 hashes of the PRE server certificate(s).
        // Replace with actual hashes when the backend is available.
        certificatePinHashes: ['PLACEHOLDER_PRE_CERT_SHA256_HASH'],
      ),
      Environment.pro => const EnvironmentConfig._(
        environment: Environment.pro,
        baseUrl: 'https://api.banking-app.com/api/v1',
        connectTimeout: Duration(seconds: 10),
        receiveTimeout: Duration(seconds: 10),
        enableLogging: false,
        // SHA-256 hashes of the PRO server certificate(s).
        // Replace with actual hashes when the backend is available.
        certificatePinHashes: ['PLACEHOLDER_PRO_CERT_SHA256_HASH'],
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

  /// SHA-256 hashes of trusted server certificates for SSL pinning.
  ///
  /// Empty list disables pinning (used in mock environment).
  /// In PRE/PRO, these must match the server's leaf or intermediate
  /// certificate hash to prevent MitM attacks.
  final List<String> certificatePinHashes;

  /// Whether the app is running in production.
  bool get isProduction => environment == Environment.pro;

  /// Whether the app is running with mock data.
  bool get isMock => environment == Environment.mock;

  /// Whether certificate pinning is enabled for this environment.
  bool get isCertificatePinningEnabled => certificatePinHashes.isNotEmpty;
}
