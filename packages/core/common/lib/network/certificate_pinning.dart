import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:crypto/crypto.dart';

// ──────────────────────────────────────────────────────────────────────────────
// SSL validation result types
// ──────────────────────────────────────────────────────────────────────────────

/// Result of an SSL trust validation performed by [CertificatePinning.validatePins].
sealed class SslValidationResult {
  const SslValidationResult();
}

/// The server trust challenge passed — the connection should be allowed.
final class SslValidationAllowed extends SslValidationResult {
  const SslValidationAllowed();
}

/// The server trust challenge failed — the connection should be blocked.
final class SslValidationBlocked extends SslValidationResult {
  const SslValidationBlocked(this.reason);

  /// Why the validation was blocked.
  final SslBlockReason reason;
}

/// Describes why an SSL validation was blocked.
enum SslBlockReason {
  /// The OS detected a certificate error and no pins were configured.
  sslError,

  /// The server provided no parseable X.509 certificate.
  missingCertificate,

  /// A pin list was configured but none of the pins matched the server cert.
  pinningFailed,
}

// ──────────────────────────────────────────────────────────────────────────────
// Certificate pinning utilities
// ──────────────────────────────────────────────────────────────────────────────

/// SSL certificate-pinning utilities shared by all transport layers.
///
/// Both the native [HttpClient] (Dio) and the WebView use [validatePins] and
/// [sha256Fingerprint] so the pinning logic lives in a single place.
///
/// **Validation rules**
/// - No [pinHashes] configured → allow if [hasSslError] is false, block otherwise.
/// - [pinHashes] configured but no cert bytes provided → block ([SslBlockReason.missingCertificate]).
/// - [pinHashes] configured → allow if any cert or SPKI hash matches, block otherwise.
class CertificatePinning {
  const CertificatePinning._();

  static const _tag = 'CertificatePinning';

  /// Creates an [HttpClient] that validates the server certificate against
  /// the provided SHA-256 [pinHashes].
  ///
  /// If [pinHashes] is empty, returns a default [HttpClient] with no pinning.
  ///
  /// **Important — certificate hashes only**: `dart:io`'s [X509Certificate] does
  /// not expose the SubjectPublicKeyInfo (SPKI) DER bytes, so only full
  /// certificate hashes are checked here. All hashes in [pinHashes] must be
  /// SHA-256 fingerprints of the full DER-encoded certificate (not SPKI hashes).
  /// SPKI pinning is not supported on either transport path.
  static HttpClient createPinnedHttpClient(List<String> pinHashes) {
    if (pinHashes.isEmpty) return HttpClient();

    return HttpClient()
      ..badCertificateCallback = (cert, host, port) {
        final result = validatePins(
          pinHashes: pinHashes,
          certDerBytes: cert.der,
        );

        if (result is SslValidationBlocked) {
          developer.log(
            'Certificate pinning failed for $host:$port.',
            name: _tag,
          );
        }

        return result is SslValidationAllowed;
      };
  }

  /// Validates DER-encoded certificate bytes against a flat list of SHA-256
  /// [pinHashes] (base64-encoded).
  ///
  /// Pass [certDerBytes] for certificate pinning. Must be non-null when
  /// [pinHashes] is non-empty, otherwise [SslBlockReason.missingCertificate]
  /// is returned.
  ///
  /// Set [hasSslError] to true when the OS already reported an SSL error for
  /// the connection — used to block un-pinned hosts that fail OS validation.
  static SslValidationResult validatePins({
    required List<String> pinHashes,
    List<int>? certDerBytes,
    bool hasSslError = false,
  }) {
    if (pinHashes.isEmpty) {
      return hasSslError
          ? const SslValidationBlocked(SslBlockReason.sslError)
          : const SslValidationAllowed();
    }

    if (certDerBytes == null) {
      return const SslValidationBlocked(SslBlockReason.missingCertificate);
    }

    final certHash = sha256Fingerprint(certDerBytes);
    if (pinHashes.contains(certHash)) {
      developer.log('SSL pinning OK [cert]', name: _tag);
      return const SslValidationAllowed();
    }

    developer.log(
      'CRITICAL SSL ALERT (Possible MitM). No configured pin matched. Blocking connection.',
      name: _tag,
    );
    return const SslValidationBlocked(SslBlockReason.pinningFailed);
  }

  /// Computes the SHA-256 fingerprint of [derBytes] as a base64-encoded string.
  ///
  /// Accepts any DER-encoded bytes — typically a full certificate or a
  /// SubjectPublicKeyInfo (SPKI) block for public-key pinning.
  static String sha256Fingerprint(List<int> derBytes) {
    final digest = sha256.convert(derBytes);
    return base64Encode(digest.bytes);
  }
}
