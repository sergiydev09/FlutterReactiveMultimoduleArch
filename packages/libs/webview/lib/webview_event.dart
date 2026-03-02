/// Events emitted by the banking WebView.
sealed class WebViewEvent {
  const WebViewEvent();
}

/// The WebView requests to be closed.
final class WebViewCloseEvent extends WebViewEvent {
  const WebViewCloseEvent();
}

/// The WebView navigated to a new URL.
final class WebViewNavigateEvent extends WebViewEvent {
  const WebViewNavigateEvent({required this.url});

  /// The URL that was navigated to.
  final String url;
}

/// The session expired while in the WebView.
final class WebViewSessionExpiredEvent extends WebViewEvent {
  const WebViewSessionExpiredEvent();
}

/// A custom event dispatched from the WebView's JavaScript bridge.
final class WebViewCustomEvent extends WebViewEvent {
  const WebViewCustomEvent({
    required this.name,
    this.data,
  });

  /// Event name identifier.
  final String name;

  /// Optional event payload.
  final Map<String, dynamic>? data;
}
