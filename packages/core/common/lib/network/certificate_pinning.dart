import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:crypto/crypto.dart';

/// Configures SSL certificate pinning for [HttpClient].
///
/// Validates the server's certificate SHA-256 hash against a list of
/// trusted hashes. If none match, the connection is rejected.
///
/// This prevents MitM attacks even if a rogue CA certificate is installed
/// on the device.
class CertificatePinning {
  const CertificatePinning._();

  static const _tag = 'CertificatePinning';

  /// Creates an [HttpClient] that validates the server certificate against
  /// the provided SHA-256 [pinHashes].
  ///
  /// If [pinHashes] is empty, returns a default [HttpClient] with no pinning.
  static HttpClient createPinnedHttpClient(List<String> pinHashes) {
    if (pinHashes.isEmpty) return HttpClient();

    return HttpClient()
      ..badCertificateCallback = (cert, host, port) {
        final certHash = _sha256Fingerprint(cert);
        final matches = pinHashes.any(
          (pin) => pin.toUpperCase() == certHash.toUpperCase(),
        );

        if (!matches) {
          developer.log(
            'Certificate pinning failed for $host:$port. '
            'Hash: $certHash',
            name: _tag,
          );
        }

        return matches;
      };
  }

  /// Computes the SHA-256 hash of the certificate's DER-encoded bytes.
  static String _sha256Fingerprint(X509Certificate cert) {
    final bytes = cert.der;
    final digest = sha256.convert(bytes);
    return base64Encode(digest.bytes);
  }
}
