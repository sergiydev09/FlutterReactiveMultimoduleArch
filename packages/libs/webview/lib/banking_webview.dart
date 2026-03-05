import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import './js_bridge.dart';
import './webview_config.dart';
import './webview_event.dart';

/// A configurable WebView widget for banking-related web content.
///
/// Loads a remote [url] and optionally communicates with the page
/// via a bidirectional [JsBridge].
///
/// When [initialData] is provided, its result is sent to the web page
/// via the JS bridge once the page finishes loading.
class BankingWebView extends StatefulWidget {
  const BankingWebView({
    required this.url,
    super.key,
    this.config = const WebViewConfig(),
    this.onEvent,
    this.initialData,
  });

  /// The URL to load.
  final String url;

  /// WebView configuration.
  final WebViewConfig config;

  /// Callback for WebView events.
  final void Function(WebViewEvent event)? onEvent;

  /// Async function that provides initial data to send to the web page
  /// via the JS bridge once the page loads.
  final Future<Map<String, dynamic>> Function()? initialData;

  @override
  State<BankingWebView> createState() => _BankingWebViewState();
}

class _BankingWebViewState extends State<BankingWebView> {
  bool _isLoading = true;
  double _progress = 0;
  late final JsBridge? _bridge;

  @override
  void initState() {
    super.initState();
    _bridge = widget.onEvent != null
        ? JsBridge(onEvent: widget.onEvent!)
        : null;
  }

  void _onWebViewCreated(InAppWebViewController controller) {
    _bridge?.register(controller);
  }

  Future<void> _onLoadStop(InAppWebViewController controller, WebUri? url) async {
    setState(() {
      _isLoading = false;
    });

    if (widget.initialData != null && _bridge != null) {
      final data = await widget.initialData!();
      await _bridge.sendToWeb(controller, data);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        InAppWebView(
          initialUrlRequest: URLRequest(url: WebUri(widget.url)),
          initialSettings: InAppWebViewSettings(
            javaScriptEnabled: widget.config.enableJavaScript,
            supportZoom: widget.config.enableZoom,
            userAgent: widget.config.userAgent,
            useShouldOverrideUrlLoading: true,
          ),
          onWebViewCreated: _onWebViewCreated,
          shouldOverrideUrlLoading: (controller, navigationAction) async {
            final navUrl = navigationAction.request.url?.toString() ?? '';
            if (!widget.config.isAllowedUrl(navUrl)) {
              return NavigationActionPolicy.CANCEL;
            }
            widget.onEvent?.call(WebViewNavigateEvent(url: navUrl));
            return NavigationActionPolicy.ALLOW;
          },
          onLoadStart: (controller, url) {
            setState(() {
              _isLoading = true;
            });
          },
          onLoadStop: _onLoadStop,
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
