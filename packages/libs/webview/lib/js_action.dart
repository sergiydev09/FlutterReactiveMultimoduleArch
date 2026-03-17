import './webview_event.dart';

/// Contract for a JavaScript action that is injected into a WebView page
/// and can optionally handle messages posted back through the JS bridge.
///
/// Implement this interface to extend the WebView's JS capabilities:
/// - [script] is injected after every page load.
/// - [handleBridgeMessage] maps an incoming bridge message to a [WebViewEvent].
///
/// Example — custom deep-link action:
/// ```dart
/// final class DeepLinkJsAction implements JsAction {
///   const DeepLinkJsAction({required this.onDeepLink});
///   final void Function(String) onDeepLink;
///
///   @override
///   String get script =>
///       'window.sendDeepLink=function(url){'
///       'window.FlutterBridge.postMessage(JSON.stringify({action:"DEEP_LINK",data:{url:url}}));'
///       '};';
///
///   @override
///   WebViewEvent? handleBridgeMessage(String action, Map<String, dynamic>? data) {
///     if (action == 'DEEP_LINK') return WebViewCustomEvent(name: action, data: data);
///     return null;
///   }
/// }
/// ```
abstract interface class JsAction {
  /// JavaScript code injected into the page after every load.
  ///
  /// Return `null` if this action only handles incoming bridge messages
  /// and does not need to inject any script (e.g. when the web page is
  /// Flutter-aware and calls the bridge directly).
  String? get script;

  /// Attempts to map a bridge message to a [WebViewEvent].
  ///
  /// Returns a typed [WebViewEvent] when this action owns [action],
  /// or `null` to pass handling to the next registered action.
  WebViewEvent? handleBridgeMessage(String action, Map<String, dynamic>? data);
}

// ---------------------------------------------------------------------------
// Default actions — always injected by [WebViewConfig]
// ---------------------------------------------------------------------------

/// Maps the `CLOSE` bridge message (posted directly by a Flutter-aware page)
/// to [WebViewCloseEvent]. No script injection needed.
final class WindowCloseJsAction implements JsAction {
  const WindowCloseJsAction();

  @override
  String? get script => null;

  @override
  WebViewEvent? handleBridgeMessage(String action, Map<String, dynamic>? data) {
    if (action == 'CLOSE') return const WebViewCloseEvent();
    return null;
  }
}

/// Maps the `OPEN_NEW_WINDOW` bridge message (posted directly by a Flutter-aware
/// page) to [WebViewCustomEvent]. No script injection needed.
final class WindowOpenJsAction implements JsAction {
  const WindowOpenJsAction();

  @override
  String? get script => null;

  @override
  WebViewEvent? handleBridgeMessage(String action, Map<String, dynamic>? data) {
    if (action == 'OPEN_NEW_WINDOW') {
      return WebViewCustomEvent(name: action, data: data);
    }
    return null;
  }
}

/// Removes `target="_blank"` from all anchor tags so navigation stays
/// in-frame and `onNavigationRequest` can intercept it.
///
/// This action does not handle any incoming bridge messages.
final class BlankTargetLinksJsAction implements JsAction {
  const BlankTargetLinksJsAction();

  @override
  String? get script =>
      'document.querySelectorAll(\'a[target="_blank"]\').forEach('
      'function(a){a.removeAttribute("target");});';

  @override
  WebViewEvent? handleBridgeMessage(String action, Map<String, dynamic>? data) =>
      null;
}

/// Default list of [JsAction]s injected by [WebViewConfig] when no custom
/// list is provided.
const List<JsAction> defaultJsActions = [
  WindowCloseJsAction(),
  WindowOpenJsAction(),
  BlankTargetLinksJsAction(),
];
