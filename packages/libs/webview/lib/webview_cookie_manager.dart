import 'package:cookie_jar/cookie_jar.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Utility class to manage WebView cookies and session state.
///
/// Acts as the anti-corruption layer between Dio's cookie model ([CookieJar])
/// and the WebView's native cookie store ([WebViewCookieManager]).
///
/// [cookieManager] is injectable for testing. Defaults to the real
/// [WebViewCookieManager] when omitted.
///
/// **Note — limitations vs flutter_inappwebview:**
/// - `WebViewCookie` does not support `httpOnly` or `sameSite` attributes.
///   The server must enforce these via `Set-Cookie` response headers.
/// - Cookie deletion is global (`clearCookies()`) — there is no per-URL
///   deletion in `webview_flutter`. Clearing affects all domains.
/// - Cache clearing (`controller.clearCache()`) is an instance method on
///   [WebViewController] and is handled by [BankingWebView] directly.
///
/// ```dart
/// // Production use (default dependencies):
/// final manager = BankingCookieManager();
///
/// // Test use (injected fake):
/// final manager = BankingCookieManager(cookieManager: fakeCookieManager);
/// ```
class BankingCookieManager {
  BankingCookieManager({WebViewCookieManager? cookieManager})
      : _cookieManager = cookieManager ?? WebViewCookieManager();

  final WebViewCookieManager _cookieManager;

  /// Syncs cookies from [cookieJar] for [url] into the WebView native cookie store.
  ///
  /// Call this before loading a [BankingWebView] that requires an authenticated
  /// session previously captured by Dio (e.g. after a successful login request).
  ///
  /// Performs a global [clearCookies] before injecting to prevent ghost sessions.
  /// Note: this clears cookies for all domains, not just the target URL.
  ///
  /// Security note: `httpOnly` and `sameSite: STRICT` cannot be set via
  /// [WebViewCookie] — the server must enforce these via `Set-Cookie` headers.
  Future<void> injectFromCookieJar({
    required String url,
    required CookieJar cookieJar,
  }) async {
    final uri = Uri.parse(url);
    final cookies = await cookieJar.loadForRequest(uri);

    // Prevent ghost sessions before injecting new cookies.
    await _cookieManager.clearCookies();

    for (final cookie in cookies) {
      await _cookieManager.setCookie(
        WebViewCookie(
          name: cookie.name,
          value: cookie.value,
          domain: cookie.domain ?? uri.host,
          path: cookie.path ?? '/',
        ),
      );
    }
  }

  /// Clears all banking-related session cookies.
  ///
  /// Note: [WebViewCookieManager] only supports a global clear — all cookies
  /// across all domains are removed, not just those for the banking URL.
  /// Cache clearing is handled separately by [BankingWebView.dispose].
  ///
  /// TODO: scope this to [url] once webview_flutter adds per-domain deletion.
  // ignore: avoid_unused_parameters
  Future<void> clearBankingSession(String url) async {
    await _cookieManager.clearCookies();
  }

  /// Purges all cookies from the cookie storage.
  /// Cache clearing is handled separately by [BankingWebView.dispose].
  Future<void> clearAllWebData() async {
    await _cookieManager.clearCookies();
  }
}
