/// Configuration for the banking WebView.
class WebViewConfig {
  const WebViewConfig({
    this.allowedDomains = const [
      'banking-app.com',
      'pre-api.banking-app.com',
      'api.banking-app.com',
    ],
    this.enableJavaScript = true,
    this.enableZoom = false,
    this.userAgent,
  });

  /// List of domains the WebView is allowed to navigate to.
  final List<String> allowedDomains;

  /// Whether JavaScript is enabled.
  final bool enableJavaScript;

  /// Whether pinch-to-zoom is enabled.
  final bool enableZoom;

  /// Custom user agent string.
  final String? userAgent;

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
