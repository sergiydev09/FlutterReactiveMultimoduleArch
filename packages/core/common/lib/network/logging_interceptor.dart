import 'dart:developer' as developer;
import 'package:dio/dio.dart';

/// A simple interceptor that logs HTTP request and response details
/// to the developer console.
class LoggingInterceptor extends Interceptor {
  const LoggingInterceptor();

  static const _tag = 'HTTP';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    developer.log(
      '--> ${options.method} ${options.uri}',
      name: _tag,
    );
    if (options.data != null) {
      developer.log(
        'Body: ${options.data}',
        name: _tag,
      );
    }
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    developer.log(
      '<-- ${response.statusCode} ${response.requestOptions.uri}',
      name: _tag,
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    developer.log(
      '<-- ERROR ${err.response?.statusCode ?? 'N/A'} '
      '${err.requestOptions.uri}\n'
      '${err.message}',
      name: _tag,
    );
    handler.next(err);
  }
}
