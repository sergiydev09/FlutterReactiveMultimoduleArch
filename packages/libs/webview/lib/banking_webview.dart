import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import './js_bridge.dart';
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
  // Tracks the URL passed to loadRequest so it is always allowed on iOS —
  // WKWebView calls onNavigationRequest for the initial load too (unlike Android).
  String? _sourceUrl;

  @override
  void initState() {
    super.initState();
    _cookieManager = widget.cookieManager ?? BankingCookieManager();
    _bridge = widget.onEvent != null
        ? JsBridge(
            onEvent: widget.onEvent!,
            actions: widget.config.jsActions,
          )
        : null;
    _controller = WebViewController();
    unawaited(_initController());
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
          kDebugMode ? error.proceed() : error.cancel(),
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

  /// Injects all [WebViewConfig.jsActions] scripts into the page.
  ///
  /// Must be called on every [_onPageFinished] because the JS environment is
  /// reset on each navigation.
  Future<void> _injectJsOverrides() async {
    for (final action in widget.config.jsActions) {
      final script = action.script;
      if (script != null) await _controller.runJavaScript(script);
    }
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
    if (!kDebugMode && !widget.config.isAllowedUrl(request.url)) {
      return NavigationDecision.prevent;
    }

    widget.onEvent?.call(WebViewNavigateEvent(url: request.url));
    return NavigationDecision.navigate;
  }

  @override
  void dispose() {
    if (widget.config.clearCookiesOnDispose) {
      unawaited(_cookieManager.clearAllWebData());
      unawaited(_controller.clearCache());
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final canGoBack = await _controller.canGoBack();
        if (canGoBack) {
          await _controller.goBack();
        } else if (context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Stack(
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
      ),
    );
  }
}
