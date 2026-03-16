import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import '../config/environment.dart';
import './auth_interceptor.dart';
import './cache_config.dart';
import './certificate_pinning.dart';
import './logging_interceptor.dart';

/// Factory responsible for creating and configuring the [Dio] HTTP client.
class DioFactory {
  const DioFactory._();

  /// Creates a fully configured [Dio] instance for the given
  /// [environmentConfig].
  ///
  /// The [tokenProvider] callback supplies the current access token.
  /// The [tokenRefresher] callback is invoked to refresh an expired token.
  /// The [onAuthFailure] callback is invoked when token refresh fails.
  static Dio create({
    required EnvironmentConfig environmentConfig,
    required Future<String?> Function() tokenProvider,
    required Future<String?> Function() tokenRefresher,
    required void Function() onAuthFailure,
    CookieJar? cookieJar,
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: environmentConfig.baseUrl,
        connectTimeout: environmentConfig.connectTimeout,
        receiveTimeout: environmentConfig.receiveTimeout,
        headers: <String, dynamic>{
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Certificate pinning — only in PRE/PRO environments.
    if (environmentConfig.isCertificatePinningEnabled) {
      final pinnedClient = CertificatePinning.createPinnedHttpClient(
        environmentConfig.certificatePinHashes,
      );
      (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient =
          () => pinnedClient;
    }

    // Cookie interceptor – captures Set-Cookie responses and sends stored cookies.
    if (cookieJar != null) {
      dio.interceptors.add(CookieManager(cookieJar));
    }

    // Auth interceptor – handles token injection and 401 refresh.
    dio.interceptors.add(
      AuthInterceptor(
        tokenProvider: tokenProvider,
        tokenRefresher: tokenRefresher,
        onAuthFailure: onAuthFailure,
      ),
    );

    // In-memory cache interceptor.
    final cacheOptions = CacheConfig.defaultOptions;
    dio.interceptors.add(DioCacheInterceptor(options: cacheOptions));

    // Logging interceptor – only when enabled for the environment.
    if (environmentConfig.enableLogging) {
      dio.interceptors.add(const LoggingInterceptor());
    }

    return dio;
  }
}
