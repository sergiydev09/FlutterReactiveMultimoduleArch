import 'dart:async';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import './js_bridge.dart';
import './platform_ssl_pinning.dart';
import './webview_config.dart';
import './webview_cookie_manager.dart';
import './webview_event.dart';
import './webview_navigation_delegate.dart';
import './webview_source.dart';

/// A configurable WebView widget for banking-related web content.
///
/// Loads content from a [source] (URL or HTML) and optionally
/// communicates with the page via a bidirectional [JsBridge].
///
/// When [initialData] is provided, its result is sent to the web page
/// via the JS bridge once the page finishes loading.
class BankingWebView extends StatefulWidget {
  const BankingWebView({
    required this.source,
    super.key,
    this.config = const WebViewConfig(),
    this.onEvent,
    this.initialData,
    this.cookieManager,
  });

  /// The source of the content to load (URL or HTML).
  final WebViewSource source;

  /// WebView configuration.
  final WebViewConfig config;

  /// Callback for WebView events.
  final void Function(WebViewEvent event)? onEvent;

  /// Async function that provides initial data to send to the web page
  /// via the JS bridge once the page loads.
  final Future<Map<String, dynamic>> Function()? initialData;

  /// Cookie manager used to clear the session on dispose.
  ///
  /// Defaults to [BankingCookieManager] with real webview_flutter dependencies.
  /// Inject a custom instance in tests to avoid touching the native layer.
  final BankingCookieManager? cookieManager;

  @override
  State<BankingWebView> createState() => _BankingWebViewState();
}

class _BankingWebViewState extends State<BankingWebView> {
  late final WebViewController _controller;
  late final JsBridge? _bridge;
  late final BankingCookieManager _cookieManager;
  bool _isLoading = true;
  double _progress = 0;

  @override
  void initState() {
    super.initState();
    _cookieManager = widget.cookieManager ?? BankingCookieManager();
    // Wrap the caller's onEvent so JS bridge CLOSE actions map to WebViewCloseEvent.
    _bridge = widget.onEvent != null
        ? JsBridge(onEvent: _handleBridgeEvent)
        : null;
    _controller = WebViewController();
    unawaited(_initController());
  }

  /// Maps bridge custom events to typed WebView events where needed.
  ///
  /// `window.close` posts action 'CLOSE' through the JS bridge.
  /// We convert it to [WebViewCloseEvent] to match the original native callback.
  void _handleBridgeEvent(WebViewEvent event) {
    if (event is WebViewCustomEvent && event.name == 'CLOSE') {
      widget.onEvent?.call(const WebViewCloseEvent());
      return;
    }
    widget.onEvent?.call(event);
  }

  Future<void> _initController() async {
    await _controller.setJavaScriptMode(
      widget.config.enableJavaScript
          ? JavaScriptMode.unrestricted
          : JavaScriptMode.disabled,
    );

    if (widget.config.userAgent != null) {
      await _controller.setUserAgent(widget.config.userAgent);
    }

    // Must register the JS channel BEFORE loadRequest / loadHtmlString.
    if (_bridge != null) {
      await _bridge.register(_controller);
    }

    await _controller.setNavigationDelegate(
      NavigationDelegate(
        onPageStarted: (_) {
          if (mounted) setState(() => _isLoading = true);
        },
        onPageFinished: (_) => _onPageFinished(),
        onProgress: (progress) {
          if (mounted) setState(() => _progress = progress / 100);
        },
        onNavigationRequest: _onNavigationRequest,
        onHttpError: (error) {
          if (error.response?.statusCode == 401) {
            widget.onEvent?.call(const WebViewSessionExpiredEvent());
          }
        },
        
        onSslAuthError: (error) => unawaited(
          PlatformSslPinning.handle(
            error: error,
            pinHashes: widget.config.sslPinHashes,
            onEvent: widget.onEvent,
          ),
        ),
      ),
    );

    // Inject session cookies before loading (URL sources only).
    final cookieJar = widget.config.cookieJar;
    final source = widget.source;
    if (cookieJar != null && source is WebViewUrlSource) {
      await _cookieManager.injectFromCookieJar(
        url: source.url,
        cookieJar: cookieJar,
      );
    }

    if (mounted) {
      await _loadSource();
    }
  }

  Future<void> _loadSource() async {
    final source = widget.source;
    switch (source) {
      case WebViewUrlSource():
        await _controller.loadRequest(
          Uri.parse(source.url),
          headers: source.headers ?? const {},
        );
      case WebViewHtmlSource():
        await _controller.loadHtmlString(
          source.htmlContent,
          baseUrl: source.baseUrl,
        );
    }
  }

  Future<void> _onPageFinished() async {
    if (!mounted) return;
    setState(() => _isLoading = false);

    // Re-inject JS overrides on every page load — JS state is cleared on navigation.
    if (widget.config.enableJavaScript) {
      await _injectJsOverrides();
    }

    // Send initial data via the bridge once the page is ready.
    if (widget.initialData != null && _bridge != null) {
      final data = await widget.initialData!();
      if (mounted) {
        await _bridge.sendToWeb(_controller, data);
      }
    }
  }

  /// Injects overrides for `window.close`, `window.open`, and `target="_blank"`.
  ///
  /// Must be called on every [_onPageFinished] because the JS environment is
  /// reset on each navigation.
  Future<void> _injectJsOverrides() async {
    // window.close → WebViewCloseEvent (via JsBridge action 'CLOSE').
    await _controller.runJavaScript(
      'window.close=function(){if(window.FlutterBridge){window.FlutterBridge.postMessage(JSON.stringify({action:"CLOSE",data:null}));}};',
    );

    // window.open → WebViewCustomEvent(name: 'OPEN_NEW_WINDOW').
    await _controller.runJavaScript(
      'window.open=function(url){if(window.FlutterBridge){window.FlutterBridge.postMessage(JSON.stringify({action:"OPEN_NEW_WINDOW",data:{url:String(url)}}));}};',
    );

    // target="_blank" links → navigate in-frame so onNavigationRequest can intercept.
    await _controller.runJavaScript(
      'document.querySelectorAll(\'a[target="_blank"]\').forEach(function(a){a.removeAttribute("target");});',
    );
  }

  Future<NavigationDecision> _onNavigationRequest(
    NavigationRequest request,
  ) async {
    // Priority 1: chain-of-responsibility navigation actions.
    final policy = await widget.config.navigationDelegate(request.url);
    if (policy != null) {
      return switch (policy) {
        WebViewNavigationPolicy.allow => NavigationDecision.navigate,
        WebViewNavigationPolicy.cancel => NavigationDecision.prevent,
      };
    }

    // Priority 2: domain allow-list.
    if (!widget.config.isAllowedUrl(request.url)) {
      return NavigationDecision.prevent;
    }

    widget.onEvent?.call(WebViewNavigateEvent(url: request.url));
    return NavigationDecision.navigate;
  }

  @override
  void dispose() {
    if (widget.config.clearCookiesOnDispose) {
      final source = widget.source;
      if (source is WebViewUrlSource) {
        unawaited(_cookieManager.clearBankingSession(source.url));
      }
      unawaited(_controller.clearCache());
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        WebViewWidget(controller: _controller),
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
