import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';

import './webview_navigation_delegate.dart';

/// Collection of standard [BankNavigationAction] implementations that handle
/// common URI schemes a banking WebView may encounter.
///
/// These are intentionally framework-agnostic at the feature level:
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
// Helpers
// ---------------------------------------------------------------------------

/// Shared helper: launches [uri] with [LaunchMode.externalApplication] so the
/// OS always routes to the correct native app, avoiding the in-app browser on
/// iOS. Logs a warning in debug mode if the launch fails.
///
/// We avoid using `canLaunchUrl` here to prevent silent failures on platforms
/// where it might return false even if the app exists (like iOS simulators).
Future<void> _launch(Uri uri) async {
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
  const TelNavigationAction();

  @override
  bool matches(String url) => url.startsWith('tel:');

  @override
  Future<NavigationActionPolicy> onMatch(String url) async {
    await _launch(Uri.parse(url));
    return NavigationActionPolicy.CANCEL;
  }
}

/// Handles `mailto:` links by opening the device's default email client.
///
/// Example URL: `mailto:soporte@banco.com?subject=Ayuda`
class MailToNavigationAction implements BankNavigationAction {
  const MailToNavigationAction();

  @override
  bool matches(String url) => url.startsWith('mailto:');

  @override
  Future<NavigationActionPolicy> onMatch(String url) async {
    await _launch(Uri.parse(url));
    return NavigationActionPolicy.CANCEL;
  }
}

/// Handles `sms:` and `smsto:` links by opening the device's SMS app.
///
/// `smsto:` is normalised to `sms:` for cross-platform consistency.
///
/// Example URL: `sms:+34600000000` or `smsto:+34600000000`
class SmsNavigationAction implements BankNavigationAction {
  const SmsNavigationAction();

  @override
  bool matches(String url) =>
      url.startsWith('sms:') || url.startsWith('smsto:');

  @override
  Future<NavigationActionPolicy> onMatch(String url) async {
    // Normalise smsto: → sms: for cross-platform compatibility.
    final normalized = url.replaceFirst('smsto:', 'sms:');
    await _launch(Uri.parse(normalized));
    return NavigationActionPolicy.CANCEL;
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
  const MapsNavigationAction();

  @override
  bool matches(String url) =>
      url.startsWith('geo:') ||
      url.startsWith('maps:') ||
      url.startsWith('comgooglemaps:');

  @override
  Future<NavigationActionPolicy> onMatch(String url) async {
    if (url.startsWith('comgooglemaps:')) {
      await _handleGoogleMaps(url);
    } else {
      await _launch(Uri.parse(url));
    }
    return NavigationActionPolicy.CANCEL;
  }

  /// Tries to open Google Maps; falls back to Apple Maps (`maps:`) if not
  /// installed.
  Future<void> _handleGoogleMaps(String url) async {
    final googleUri = Uri.parse(url);
    try {
      if (await canLaunchUrl(googleUri)) {
        await launchUrl(googleUri, mode: LaunchMode.externalApplication);
        return;
      }
    } on Exception catch (_) {}
    
    // Fallback to Apple Maps.
    final appleMapsSuffix = url.substring('comgooglemaps:'.length);
    await _launch(Uri.parse('maps:$appleMapsSuffix'));
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
  const AppStoreNavigationAction();

  @override
  bool matches(String url) =>
      url.startsWith('market:') ||
      url.startsWith('play:') ||
      url.startsWith('itms-apps:') ||
      url.startsWith('itms:');

  @override
  Future<NavigationActionPolicy> onMatch(String url) async {
    await _launch(Uri.parse(url));
    return NavigationActionPolicy.CANCEL;
  }
}
