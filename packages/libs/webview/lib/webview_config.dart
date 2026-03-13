import './webview_navigation_delegate.dart';

/// Configuration for the banking WebView.
class WebViewConfig {
  const WebViewConfig({
    this.allowedDomains = const [
      'banking-app.com',
      'pre-api.banking-app.com',
      'api.banking-app.com',
    ],
    this.enableJavaScript = false, // TODO: ask sergiy if set enable js
    this.enableZoom = false,
    this.supportMultipleWindows = false,
    this.clearCookiesOnDispose = true,
    this.userAgent,
    this.navigationDelegate = const WebViewNavigationDelegate(),
  });

  /// List of domains the WebView is allowed to navigate to.
  final List<String> allowedDomains;

  /// Whether JavaScript is enabled.
  final bool enableJavaScript;

  /// Whether pinch-to-zoom is enabled.
  final bool enableZoom;

  /// Whether to support opening multiple windows (pop-ups).
  final bool supportMultipleWindows;

  /// Whether to clear cookies when the WebView is disposed (security best practice).
  final bool clearCookiesOnDispose;

  /// Custom user agent string.
  final String? userAgent;

  /// The delegate responsible for evaluating navigation actions.
  ///
  /// Construct it with your [BankNavigationAction]s:
  /// ```dart
  /// WebViewConfig(
  ///   navigationDelegate: WebViewNavigationDelegate(
  ///     actions: [
  ///       TelSchemeAction(onCall: (number) => launchUrl(...)),
  ///       TransactionSuccessAction(onSuccess: () => Navigator.pop(context)),
  ///     ],
  ///   ),
  /// )
  /// ```
  final WebViewNavigationDelegate navigationDelegate;

  /// Checks whether the given [url] belongs to an allowed domain.
  bool isAllowedUrl(String url) {
    if (allowedDomains.isEmpty) return true;
    final uri = Uri.tryParse(url);
    if (uri == null) return false;
    return allowedDomains.any(
      (domain) => uri.host == domain || uri.host.endsWith('.$domain'),
    );
  }
}
