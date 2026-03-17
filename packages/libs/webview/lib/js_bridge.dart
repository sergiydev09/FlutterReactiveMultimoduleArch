import 'dart:convert';
import 'dart:developer' as developer;

import 'package:webview_flutter/webview_flutter.dart';

import './js_action.dart';
import './webview_event.dart';

/// Handles bidirectional JavaScript bridge communication between
/// Flutter and the WebView content.
///
/// Incoming bridge messages are dispatched to the registered [actions] in
/// order. The first action that returns a non-null [WebViewEvent] from
/// [JsAction.handleBridgeMessage] wins; unhandled messages are logged and
/// discarded.
class JsBridge {
  JsBridge({
    required this.onEvent,
    required this.actions,
    this.channelName = 'FlutterBridge',
  });

  /// Name of the JS channel registered in the WebView.
  final String channelName;

  /// Ordered list of actions that can handle incoming bridge messages.
  final List<JsAction> actions;

  /// Callback for events received from JS.
  final void Function(WebViewEvent event) onEvent;

  static const _tag = 'JsBridge';

  /// Registers the JS channel on the given [controller].
  ///
  /// Must be called **before** [WebViewController.loadRequest] or
  /// [WebViewController.loadHtmlString] so the channel is available
  /// when the page executes JavaScript.
  ///
  /// The web page can call:
  /// ```js
  /// window.FlutterBridge.postMessage(JSON.stringify(payload));
  /// ```
  Future<void> register(WebViewController controller) async {
    await controller.addJavaScriptChannel(
      channelName,
      onMessageReceived: (msg) => _handleMessage(msg.message),
    );
    developer.log('Channel "$channelName" registered', name: _tag);
  }

  /// Sends data from Flutter to the WebView by calling
  /// `window.onFlutterData(jsonString)` in the loaded page.
  ///
  /// The argument is passed as a **JSON string** (not a JS object literal) so
  /// that the web page can call `JSON.parse(data)` on it. To achieve this the
  /// JSON-encoded map is double-encoded: the outer `jsonEncode` turns the JSON
  /// string into a valid JS string literal with all inner quotes escaped.
  Future<void> sendToWeb(
    WebViewController controller,
    Map<String, dynamic> data,
  ) async {
    final json = jsonEncode(data);
    final jsStringArg = jsonEncode(json); // produces a quoted, escaped JS string
    await controller.runJavaScript(
      'if(window.onFlutterData) window.onFlutterData($jsStringArg);',
    );
    developer.log('Sent data to web: ${data.keys}', name: _tag);
  }

  void _handleMessage(String rawMessage) {
    try {
      final decoded = jsonDecode(rawMessage);
      if (decoded is! Map) {
        developer.log(
          'Unexpected bridge payload type: ${decoded.runtimeType}',
          name: _tag,
        );
        return;
      }

      final payload = Map<String, dynamic>.from(decoded);
      final action = payload['action'] as String? ?? 'unknown';
      final data = payload['data'] as Map<String, dynamic>?;

      for (final jsAction in actions) {
        final event = jsAction.handleBridgeMessage(action, data);
        if (event != null) {
          onEvent(event);
          developer.log('Received action: $action', name: _tag);
          return;
        }
      }
      developer.log('Unhandled bridge action: $action', name: _tag);
    } on FormatException catch (e) {
      developer.log('Error parsing bridge message: $e', name: _tag);
    } on Exception catch (e) {
      developer.log('Error handling bridge message: $e', name: _tag);
    }
  }
}
