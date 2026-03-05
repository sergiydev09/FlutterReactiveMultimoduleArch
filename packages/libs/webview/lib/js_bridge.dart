import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import './webview_event.dart';

/// Handles bidirectional JavaScript bridge communication between
/// Flutter and the WebView content.
class JsBridge {
  JsBridge({
    required this.onEvent,
    this.channelName = 'FlutterBridge',
  });

  /// Name of the JS handler registered in the WebView.
  final String channelName;

  /// Callback for events received from JS.
  final void Function(WebViewEvent event) onEvent;

  static const _tag = 'JsBridge';

  /// Registers the JS handler on the given [controller].
  ///
  /// The web page can call:
  /// ```js
  /// window.flutter_inappwebview.callHandler('FlutterBridge', payload);
  /// ```
  void register(InAppWebViewController controller) {
    controller.addJavaScriptHandler(
      handlerName: channelName,
      callback: _handleMessage,
    );
    developer.log('Handler "$channelName" registered', name: _tag);
  }

  /// Sends data from Flutter to the WebView by calling
  /// `window.onFlutterData(jsonString)` in the loaded page.
  Future<void> sendToWeb(
    InAppWebViewController controller,
    Map<String, dynamic> data,
  ) async {
    final jsonString = jsonEncode(data);
    final escaped = jsonString.replaceAll(r'\', r'\\').replaceAll("'", r"\'");
    await controller.evaluateJavascript(
      source: "if(window.onFlutterData) window.onFlutterData('$escaped');",
    );
    developer.log('Sent data to web: ${data.keys}', name: _tag);
  }

  dynamic _handleMessage(List<dynamic> args) {
    if (args.isEmpty) return null;

    try {
      final Map<String, dynamic> payload;
      if (args.first is Map) {
        payload = Map<String, dynamic>.from(args.first as Map);
      } else if (args.first is String) {
        payload =
            Map<String, dynamic>.from(jsonDecode(args.first as String) as Map);
      } else {
        developer.log('Unexpected bridge payload type: ${args.first.runtimeType}', name: _tag);
        return null;
      }

      final action = payload['action'] as String? ?? 'unknown';
      final data = payload['data'] as Map<String, dynamic>?;

      onEvent(WebViewCustomEvent(name: action, data: data));
      developer.log('Received action: $action', name: _tag);
    } on FormatException catch (e) {
      developer.log('Error parsing bridge message: $e', name: _tag);
    } on Exception catch (e) {
      developer.log('Error handling bridge message: $e', name: _tag);
    }

    return null;
  }
}
