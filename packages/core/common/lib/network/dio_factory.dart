import 'package:common/config/environment.dart';
import 'package:common/network/auth_interceptor.dart';
import 'package:common/network/cache_config.dart';
import 'package:common/network/logging_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';

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
