import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

/// Utility class to manage WebView cookies and session state.
///
/// Acts as the anti-corruption layer between Dio's cookie model ([CookieJar])
/// and the WebView's native cookie store ([CookieManager]).
///
/// [cookieManager] and [clearCache] are injectable for testing. Both default
/// to the real InAppWebView implementations when omitted.
///
/// ```dart
/// // Production use (default dependencies):
/// final manager = BankingCookieManager();
///
/// // Test use (injected fakes):
/// final manager = BankingCookieManager(
///   cookieManager: fakeCookieManager,
///   clearCache: () async {},
/// );
/// ```
class BankingCookieManager {
  BankingCookieManager({
    CookieManager? cookieManager,
    Future<void> Function()? clearCache,
  })  : _cookieManager = cookieManager ?? CookieManager.instance(),
        _clearCache = clearCache ?? InAppWebViewController.clearAllCache;

  final CookieManager _cookieManager;
  final Future<void> Function() _clearCache;

  /// Syncs cookies from [cookieJar] for [url] into the WebView native cookie store.
  ///
  /// Call this before opening a [BankingWebView] that requires an authenticated
  /// session previously captured by Dio (e.g. after a successful login request).
  ///
  /// The [cookieJar] should be the shared instance from `CommonProviders.cookieJar`.
  ///
  /// Security: [sameSite] is enforced as `STRICT` regardless of the server flag,
  /// as a banking defence-in-depth measure.
  Future<void> injectFromCookieJar({
    required String url,
    required CookieJar cookieJar,
  }) async {
    final uri = Uri.parse(url);
    final webUri = WebUri(url);

    final cookies = await cookieJar.loadForRequest(uri);

    // Prevent ghost sessions before injecting new cookies.
    await _cookieManager.deleteCookies(url: webUri);

    for (final cookie in cookies) {
      await _cookieManager.setCookie(
        url: webUri,
        name: cookie.name,
        value: cookie.value,
        domain: cookie.domain,
        path: cookie.path ?? '/',
        isSecure: cookie.secure,
        isHttpOnly: cookie.httpOnly,
        sameSite: HTTPCookieSameSitePolicy.STRICT,
      );
    }
  }

  /// Clears all banking-related session data.
  ///
  /// Deletes cookies for the specified [url] and clears the webview cache.
  Future<void> clearBankingSession(String url) async {
    await _cookieManager.deleteCookies(url: WebUri(url));
    await _clearCache();
  }

  /// Purges everything in the cookie storage and cache.
  /// Use with caution.
  Future<void> clearAllWebData() async {
    await _cookieManager.deleteAllCookies();
    await _clearCache();
  }
}
