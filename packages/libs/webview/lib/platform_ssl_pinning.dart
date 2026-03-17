import 'package:common/network/certificate_pinning.dart';
import 'package:webview_flutter/webview_flutter.dart';

import './webview_config.dart';
import './webview_event.dart';

/// Handles WebView SSL certificate validation against [WebViewConfig.sslPinHashes].
///
/// Bridges [SslAuthError] to [CertificatePinning.validatePins] — the single
/// source of truth for pin verification shared with the Dio HTTP layer.
///
/// **No native platform channel required**: `webview_flutter` 4.13+ exposes
/// DER bytes via `SslAuthError.certificate.data` on both Android
/// (`AndroidSslAuthError` via `X509Certificate.getEncoded()`) and iOS
/// (`WebKitSslAuthError` via `SecCertificate` data in the trust chain).
///
/// ### Limitation — OS-trusted certs are not intercepted
/// `NavigationDelegate.onSslAuthError` fires **only** when the OS already
/// detected an SSL error (expired cert, untrusted CA, hostname mismatch).
/// HTTPS connections whose certificates pass OS validation are never surfaced
/// to Dart, so configured pins cannot be checked against them.
///
/// Practical consequences:
/// - `pinHashes` empty → any OS SSL error blocks the connection.
/// - `pinHashes` non-empty → pins are checked when OS flags an error (enables
///   trust-override for pinned self-signed / private-CA certs). OS-trusted
///   certs that do NOT match your pins will still succeed.
///
/// If strict SPKI/cert-hash pinning against OS-trusted certs is required,
/// a native Method Channel intercepting `URLAuthenticationChallenge` (iOS) or
/// `onReceivedClientCertRequest` (Android) would be needed.
class PlatformSslPinning {
  const PlatformSslPinning._();

  /// Validates the server certificate in [error] against [pinHashes] and
  /// calls proceed or cancel on the connection accordingly.
  ///
  /// If [onEvent] is provided, emits a [WebViewCustomEvent] with the block
  /// reason before cancelling the connection:
  /// - `'SECURITY_SSL_ERROR'` — SSL error with no configured pins
  /// - `'SECURITY_SSL_MISSING'` — pins configured but DER bytes unavailable
  /// - `'SECURITY_SSL_PINNING_FAILED'` — cert does not match any configured pin
  static Future<void> handle({
    required SslAuthError error,
    required List<String> pinHashes,
    void Function(WebViewEvent)? onEvent,
  }) async {
    final certData = error.certificate?.data;
    final result = CertificatePinning.validatePins(
      pinHashes: pinHashes,
      // onSslAuthError only fires when the OS already detected a problem.
      hasSslError: true,
      certDerBytes: certData != null ? List<int>.from(certData) : null,
    );

    switch (result) {
      case SslValidationAllowed():
        await error.proceed();
      case SslValidationBlocked(:final reason):
        final eventName = switch (reason) {
          SslBlockReason.sslError => 'SECURITY_SSL_ERROR',
          SslBlockReason.missingCertificate => 'SECURITY_SSL_MISSING',
          SslBlockReason.pinningFailed => 'SECURITY_SSL_PINNING_FAILED',
        };
        onEvent?.call(WebViewCustomEvent(name: eventName));
        await error.cancel();
    }
  }
}
