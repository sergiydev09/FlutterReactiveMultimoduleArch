import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:webview_lib/webview_config.dart';
import 'package:webview_lib/webview_event.dart';

/// A configurable WebView widget for banking-related web content.
///
/// Shows a loading indicator while the page loads and enforces
/// domain restrictions via [WebViewConfig].
class BankingWebView extends StatefulWidget {
  const BankingWebView({
    required this.url,
    super.key,
    this.isAuthenticated = false,
    this.config = const WebViewConfig(),
    this.onEvent,
  });

  /// The URL to load.
  final String url;

  /// Whether the user is currently authenticated.
  final bool isAuthenticated;

  /// WebView configuration.
  final WebViewConfig config;

  /// Callback for WebView events.
  final void Function(WebViewEvent event)? onEvent;

  @override
  State<BankingWebView> createState() => _BankingWebViewState();
}

class _BankingWebViewState extends State<BankingWebView> {
  bool _isLoading = true;
  double _progress = 0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        InAppWebView(
          initialUrlRequest: URLRequest(
            url: WebUri(widget.url),
          ),
          initialSettings: InAppWebViewSettings(
            javaScriptEnabled: widget.config.enableJavaScript,
            supportZoom: widget.config.enableZoom,
            userAgent: widget.config.userAgent,
            useShouldOverrideUrlLoading: true,
          ),
          shouldOverrideUrlLoading: (controller, navigationAction) async {
            final url = navigationAction.request.url?.toString() ?? '';
            if (!widget.config.isAllowedUrl(url)) {
              return NavigationActionPolicy.CANCEL;
            }
            widget.onEvent?.call(WebViewNavigateEvent(url: url));
            return NavigationActionPolicy.ALLOW;
          },
          onLoadStart: (controller, url) {
            setState(() {
              _isLoading = true;
            });
          },
          onLoadStop: (controller, url) {
            setState(() {
              _isLoading = false;
            });
          },
          onProgressChanged: (controller, progress) {
            setState(() {
              _progress = progress / 100;
            });
          },
          onReceivedHttpError: (controller, request, errorResponse) {
            if (errorResponse.statusCode == 401) {
              widget.onEvent?.call(const WebViewSessionExpiredEvent());
            }
          },
          onCloseWindow: (controller) {
            widget.onEvent?.call(const WebViewCloseEvent());
          },
        ),
        if (_isLoading)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: LinearProgressIndicator(
              value: _progress > 0 ? _progress : null,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
            ),
          ),
      ],
    );
  }
}
