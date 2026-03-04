import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import './otp_config.dart';
import './otp_flow.dart';
import './otp_result.dart';

/// Dio interceptor that detects OTP-required responses and triggers the
/// OTP verification flow before retrying the original request.
class OtpInterceptor extends Interceptor {
  OtpInterceptor({
    required this.navigatorKey,
    this.config = const OtpConfig(),
  });

  /// Global navigator key used to show the OTP dialog.
  final GlobalKey<NavigatorState> navigatorKey;

  /// OTP configuration.
  final OtpConfig config;

  static const _otpRequiredHeader = 'X-OTP-Required';

  @override
  Future<void> onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) async {
    final otpRequired = response.headers.value(_otpRequiredHeader);

    if (otpRequired != null && otpRequired.toLowerCase() == 'true') {
      final context = navigatorKey.currentContext;
      if (context == null) {
        handler.next(response);
        return;
      }

      final result = await showModalBottomSheet<OtpResult>(
        context: context,
        isDismissible: false,
        enableDrag: false,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (_) => OtpFlowWidget(config: config),
      );

      if (result == OtpResult.verified) {
        // Retry the original request after successful verification.
        try {
          final options = response.requestOptions;
          options.headers['X-OTP-Token'] = 'verified';
          final dio = Dio(
            BaseOptions(
              baseUrl: options.baseUrl,
              headers: options.headers,
            ),
          );
          final retryResponse = await dio.fetch<dynamic>(options);
          return handler.resolve(retryResponse);
        } on Exception catch (e) {
          return handler.reject(
            DioException(
              requestOptions: response.requestOptions,
              error: e,
            ),
          );
        }
      }
    }

    handler.next(response);
  }
}
