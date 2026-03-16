import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

import './webview_navigation_delegate.dart';

/// Collection of standard [BankNavigationAction] implementations that handle
/// common URI schemes a banking WebView may encounter.
///
/// These are framework-agnostic at the feature level:
/// simply add the ones you need to `WebViewConfig.navigationDelegate`.
///
/// ```dart
/// WebViewNavigationDelegate(
///   actions: [
///     TelNavigationAction(),
///     MailToNavigationAction(),
///     SmsNavigationAction(),
///     MapsNavigationAction(),
///     AppStoreNavigationAction(),
///   ],
/// )
/// ```

// ---------------------------------------------------------------------------
// Default launcher
// ---------------------------------------------------------------------------

/// Default URL launcher used by all actions. Launches [uri] via the OS so it
/// always routes to the correct native app.
///
/// We avoid `canLaunchUrl` here to prevent silent failures on platforms where
/// it might return false even if the app exists (e.g. iOS simulators).
Future<void> _defaultLaunch(Uri uri) async {
  try {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } on Exception catch (e) {
    debugPrint(
      '[BankNavigationAction] Failed to launch $uri: $e\n'
      'Check LSApplicationQueriesSchemes (iOS) / <queries> (Android).',
    );
  }
}

// ---------------------------------------------------------------------------
// Standard Communication
// ---------------------------------------------------------------------------

/// Handles `tel:` links by opening the device's native phone dialer.
///
/// Example URL: `tel:+34900123456`
class TelNavigationAction implements BankNavigationAction {
  TelNavigationAction({Future<void> Function(Uri)? launcher})
      : _launcher = launcher ?? _defaultLaunch;

  final Future<void> Function(Uri) _launcher;

  @override
  bool matches(String url) => url.startsWith('tel:');

  @override
  Future<WebViewNavigationPolicy> onMatch(String url) async {
    await _launcher(Uri.parse(url));
    return WebViewNavigationPolicy.cancel;
  }
}

/// Handles `mailto:` links by opening the device's default email client.
///
/// Example URL: `mailto:soporte@banco.com?subject=Ayuda`
class MailToNavigationAction implements BankNavigationAction {
  MailToNavigationAction({Future<void> Function(Uri)? launcher})
      : _launcher = launcher ?? _defaultLaunch;

  final Future<void> Function(Uri) _launcher;

  @override
  bool matches(String url) => url.startsWith('mailto:');

  @override
  Future<WebViewNavigationPolicy> onMatch(String url) async {
    await _launcher(Uri.parse(url));
    return WebViewNavigationPolicy.cancel;
  }
}

/// Handles `sms:` and `smsto:` links by opening the device's SMS app.
///
/// `smsto:` is normalised to `sms:` for cross-platform consistency.
///
/// Example URL: `sms:+34600000000` or `smsto:+34600000000`
class SmsNavigationAction implements BankNavigationAction {
  SmsNavigationAction({Future<void> Function(Uri)? launcher})
      : _launcher = launcher ?? _defaultLaunch;

  final Future<void> Function(Uri) _launcher;

  @override
  bool matches(String url) =>
      url.startsWith('sms:') || url.startsWith('smsto:');

  @override
  Future<WebViewNavigationPolicy> onMatch(String url) async {
    // Normalise smsto: → sms: for cross-platform compatibility.
    final normalized = url.replaceFirst('smsto:', 'sms:');
    await _launcher(Uri.parse(normalized));
    return WebViewNavigationPolicy.cancel;
  }
}

// ---------------------------------------------------------------------------
// Maps & Location
// ---------------------------------------------------------------------------

/// Handles map-related URI schemes by opening the appropriate maps application.
///
/// Supported schemes:
/// - `geo:` — Android standard (opens default maps app).
/// - `maps:` — iOS Apple Maps.
/// - `comgooglemaps:` — iOS Google Maps (falls back to `maps:` if not installed).
///
/// Example URLs:
/// - `geo:38.26,-0.69?z=15`
/// - `maps:?q=Elche`
/// - `comgooglemaps://?q=Elche`
class MapsNavigationAction implements BankNavigationAction {
  MapsNavigationAction({
    Future<void> Function(Uri)? launcher,
    Future<bool> Function(Uri)? canLaunch,
  })  : _launcher = launcher ?? _defaultLaunch,
        _canLaunch = canLaunch ?? canLaunchUrl;

  final Future<void> Function(Uri) _launcher;
  final Future<bool> Function(Uri) _canLaunch;

  @override
  bool matches(String url) =>
      url.startsWith('geo:') ||
      url.startsWith('maps:') ||
      url.startsWith('comgooglemaps:');

  @override
  Future<WebViewNavigationPolicy> onMatch(String url) async {
    if (url.startsWith('comgooglemaps:')) {
      await _handleGoogleMaps(url);
    } else {
      await _launcher(Uri.parse(url));
    }
    return WebViewNavigationPolicy.cancel;
  }

  /// Tries to open Google Maps; falls back to Apple Maps (`maps:`) if not
  /// installed.
  Future<void> _handleGoogleMaps(String url) async {
    final googleUri = Uri.parse(url);
    try {
      if (await _canLaunch(googleUri)) {
        await _launcher(googleUri);
        return;
      }
    } on Exception catch (_) {}

    // Fallback to Apple Maps.
    final appleMapsSuffix = url.substring('comgooglemaps:'.length);
    await _launcher(Uri.parse('maps:$appleMapsSuffix'));
  }
}

// ---------------------------------------------------------------------------
// App Stores
// ---------------------------------------------------------------------------

/// Handles app store URI schemes to redirect users to download or update an app.
///
/// Supported schemes:
/// - `market:` / `play:` — Google Play Store (Android).
/// - `itms-apps:` / `itms:` — Apple App Store (iOS).
///
/// Example URLs:
/// - `market://details?id=com.tu.banco`
/// - `itms-apps://itunes.apple.com/app/id123456789`
class AppStoreNavigationAction implements BankNavigationAction {
  AppStoreNavigationAction({Future<void> Function(Uri)? launcher})
      : _launcher = launcher ?? _defaultLaunch;

  final Future<void> Function(Uri) _launcher;

  @override
  bool matches(String url) =>
      url.startsWith('market:') ||
      url.startsWith('play:') ||
      url.startsWith('itms-apps:') ||
      url.startsWith('itms:');

  @override
  Future<WebViewNavigationPolicy> onMatch(String url) async {
    await _launcher(Uri.parse(url));
    return WebViewNavigationPolicy.cancel;
  }
}
