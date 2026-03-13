import 'package:flutter_inappwebview/flutter_inappwebview.dart';

/// Data class representing a secure cookie for the Banking WebView.
class BankingCookie {
  const BankingCookie({
    required this.name,
    required this.value,
    this.domain,
    this.path = '/',
    this.isSecure = true,
    this.isHttpOnly = true,
    this.sameSite = HTTPCookieSameSitePolicy.STRICT,
  });

  final String name;
  final String value;
  final String? domain;
  final String path;
  final bool isSecure;
  final bool isHttpOnly;
  final HTTPCookieSameSitePolicy sameSite;
}

/// Utility class to manage WebView cookies and session state.
class BankingCookieManager {
  BankingCookieManager._();

  /// Injects a list of secure cookies for the given [url].
  ///
  /// By default, cookies are configured with:
  /// - [isHttpOnly]: true, making it invisible to JavaScript (XSS protection).
  /// - [isSecure]: true, ensuring it only travels over HTTPS.
  /// - [sameSite]: STRICT, preventing CSRF attacks.
  static Future<void> injectSecureCookies({
    required String url,
    required List<BankingCookie> cookies,
  }) async {
    final cookieManager = CookieManager.instance();
    final webUri = WebUri(url);

    // 1. Prevent "ghost sessions" by deleting old cookies for this URL
    await cookieManager.deleteCookies(url: webUri);

    // 2. Set the new secure cookies
    for (final cookie in cookies) {
      await cookieManager.setCookie(
        url: webUri,
        name: cookie.name,
        value: cookie.value,
        domain: cookie.domain,
        path: cookie.path,
        isSecure: cookie.isSecure,
        isHttpOnly: cookie.isHttpOnly,
        sameSite: cookie.sameSite,
      );
    }
  }

  /// Clears all banking-related session data.
  ///
  /// Deletes cookies for the specified [url] and clears the webview cache.
  static Future<void> clearBankingSession(String url) async {
    final cookieManager = CookieManager.instance();
    final webUri = WebUri(url);

    await cookieManager.deleteCookies(url: webUri);
    await InAppWebViewController.clearAllCache();
  }

  /// Purgues everything in the cookie storage and cache.
  /// Use with caution.
  static Future<void> clearAllWebData() async {
    await CookieManager.instance().deleteAllCookies();
    await InAppWebViewController.clearAllCache();
  }
}
