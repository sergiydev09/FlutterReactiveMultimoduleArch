import 'dart:developer' as developer;

import 'package:dio/dio.dart';

/// Interceptor that attaches the authorization token to every request
/// and handles automatic token refresh on 401 responses.
///
/// Uses [QueuedInterceptorsWrapper] so that concurrent requests wait
/// while the token is being refreshed, preventing duplicate refresh calls.
class AuthInterceptor extends QueuedInterceptorsWrapper {
  AuthInterceptor({
    required this.tokenProvider,
    required this.tokenRefresher,
    required this.onAuthFailure,
  });

  /// Returns the current access token, or `null` if not available.
  final Future<String?> Function() tokenProvider;

  /// Attempts to refresh the token. Returns the new token or `null` on
  /// failure.
  final Future<String?> Function() tokenRefresher;

  /// Called when token refresh fails, typically to force logout.
  final void Function() onAuthFailure;

  static const _authHeader = 'Authorization';

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await tokenProvider();
    if (token != null && token.isNotEmpty) {
      options.headers[_authHeader] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      developer.log(
        'Received 401 – attempting token refresh',
        name: 'AuthInterceptor',
      );

      try {
        final newToken = await tokenRefresher();

        if (newToken != null && newToken.isNotEmpty) {
          // Retry the original request with the new token.
          final options = err.requestOptions;
          options.headers[_authHeader] = 'Bearer $newToken';

          final dio = Dio(
            BaseOptions(
              baseUrl: options.baseUrl,
              headers: options.headers,
            ),
          );

          final response = await dio.fetch<dynamic>(options);
          return handler.resolve(response);
        }
      } on Exception catch (e) {
        developer.log(
          'Token refresh failed: $e',
          name: 'AuthInterceptor',
        );
      }

      // If we reach here, refresh failed.
      onAuthFailure();
    }

    handler.next(err);
  }
}
