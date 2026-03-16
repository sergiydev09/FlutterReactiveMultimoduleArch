import 'dart:async';

import 'package:common/network/certificate_pinning.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import './js_bridge.dart';
import './webview_config.dart';
import './webview_cookie_manager.dart';
import './webview_event.dart';
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
  /// Defaults to [BankingCookieManager] with real InAppWebView dependencies.
  /// Inject a custom instance in tests to avoid touching the native layer.
  final BankingCookieManager? cookieManager;

  @override
  State<BankingWebView> createState() => _BankingWebViewState();
}

class _BankingWebViewState extends State<BankingWebView> {
  bool _isLoading = true;
  double _progress = 0;
  late final JsBridge? _bridge;
  late final BankingCookieManager _cookieManager;

  @override
  void initState() {
    super.initState();
    _bridge = widget.onEvent != null
        ? JsBridge(onEvent: widget.onEvent!)
        : null;
    _cookieManager = widget.cookieManager ?? BankingCookieManager();
  }

  Future<void> _onWebViewCreated(InAppWebViewController controller) async {
    if (widget.config.enableJavaScript) {
      _bridge?.register(controller);
    }

    final cookieJar = widget.config.cookieJar;
    final source = widget.source;
    if (cookieJar != null && source is WebViewUrlSource) {
      await _cookieManager.injectFromCookieJar(
        url: source.url,
        cookieJar: cookieJar,
      );
    }
  }

  Future<ServerTrustAuthResponse> _onReceivedServerTrustAuthRequest(
    InAppWebViewController controller,
    URLAuthenticationChallenge challenge,
  ) async {
    final x509 = challenge.protectionSpace.sslCertificate?.x509Certificate;
    final result = CertificatePinning.validatePins(
      pinHashes: widget.config.sslPinHashes,
      certDerBytes: x509?.encoded,
      spkiDerBytes: x509?.publicKey?.derEncodedKey,
      hasSslError: challenge.protectionSpace.sslError != null,
    );
    return switch (result) {
      SslValidationAllowed() => ServerTrustAuthResponse(
          action: ServerTrustAuthResponseAction.PROCEED,
        ),
      SslValidationBlocked(:final reason) => _blocked(reason),
    };
  }

  ServerTrustAuthResponse _blocked(SslBlockReason reason) {
    final eventName = switch (reason) {
      SslBlockReason.sslError => 'SECURITY_SSL_ERROR',
      SslBlockReason.missingCertificate => 'SECURITY_SSL_MISSING',
      SslBlockReason.pinningFailed => 'SECURITY_SSL_PINNING_FAILED',
    };
    widget.onEvent?.call(WebViewCustomEvent(name: eventName));
    return ServerTrustAuthResponse();
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
  void dispose() {
    if (widget.config.clearCookiesOnDispose) {
      final source = widget.source;
      if (source is WebViewUrlSource) {
        unawaited(_cookieManager.clearBankingSession(source.url));
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    URLRequest? initialUrlRequest;
    InAppWebViewInitialData? initialData;

    switch (widget.source) {
      case WebViewUrlSource source:
        initialUrlRequest = source.toUrlRequest();
      case WebViewHtmlSource source:
        initialData = source.toInitialData();
    }

    return Stack(
      children: [
        InAppWebView(
          initialUrlRequest: initialUrlRequest,
          initialData: initialData,
          initialSettings: InAppWebViewSettings(
            javaScriptEnabled: widget.config.enableJavaScript,
            supportZoom: widget.config.enableZoom,
            userAgent: widget.config.userAgent,
            useShouldOverrideUrlLoading: true,
            supportMultipleWindows: widget.config.supportMultipleWindows,
            javaScriptCanOpenWindowsAutomatically: false,
            isInspectable: kDebugMode,
          ),
          onWebViewCreated: _onWebViewCreated,
          shouldOverrideUrlLoading: (controller, navigationAction) async {
            final navUrl = navigationAction.request.url?.toString() ?? '';

            // Priority 1: Navigation Actions (chain-of-responsibility via delegate)
            final result = await widget.config.navigationDelegate(
              controller,
              navigationAction,
            );
            if (result != null) return result;

            // Priority 2: Domain Allow-list
            if (!widget.config.isAllowedUrl(navUrl)) {
              return NavigationActionPolicy.CANCEL;
            }

            widget.onEvent?.call(WebViewNavigateEvent(url: navUrl));
            return NavigationActionPolicy.ALLOW;
          },
          onReceivedServerTrustAuthRequest: _onReceivedServerTrustAuthRequest,
          onCreateWindow: (controller, createWindowAction) async { // for _blank and other webs opening. TODO: (Ask sergiy if allowed url's must be checked here too)
            final urlToOpen = createWindowAction.request.url?.toString();
            if (urlToOpen != null && widget.config.isAllowedUrl(urlToOpen)) {
              widget.onEvent?.call(
                WebViewCustomEvent(
                  name: 'OPEN_NEW_WINDOW',
                  data: {'url': urlToOpen},
                ),
              );
              return true;
            }
            return false;
          },
          ///onPermissionRequest: (controller, permissionRequest) async {}, // TODO: (¿how should we manage this?)
          ///onReceivedError: (controller, request, error) {},
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
