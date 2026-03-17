/// Sealed class defining the source of the web content.
sealed class WebViewSource {
  const WebViewSource();
}

/// A remote URL source.
final class WebViewUrlSource extends WebViewSource {
  const WebViewUrlSource(this.url, {this.headers});

  /// The URL to load.
  final String url;

  /// Optional HTTP headers for the initial request.
  final Map<String, String>? headers;
}

/// A static HTML content source.
final class WebViewHtmlSource extends WebViewSource {
  const WebViewHtmlSource(this.htmlContent, {this.baseUrl});

  /// The HTML content to load.
  final String htmlContent;

  /// The base URL for the content (useful for resolving relative paths).
  final String? baseUrl;
}
