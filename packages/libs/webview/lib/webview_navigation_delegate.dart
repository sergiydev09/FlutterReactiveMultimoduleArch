import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import './webview_event.dart';
import 'webview_lib.dart' show BankingWebView, WebViewConfig;

/// Contract for a single navigation action.
///
/// An action is responsible for two things only (SRP):
///   1. Deciding if it applies to the given URL → [matches].
///   2. Performing its side-effect and returning a policy → [onMatch].
///
/// Actions live **outside** the `webview_lib` package, in the feature layer.
/// They depend on this interface (DIP) and never on InAppWebView internals.
///
/// ---
/// **Example – open phone dialer:**
/// ```dart
/// class TelSchemeAction implements BankNavigationAction {
///   const TelSchemeAction({required this.onCall});
///   final void Function(String number) onCall;
///
///   @override
///   bool matches(String url) => url.startsWith('tel:');
///
///   @override
///   Future<NavigationActionPolicy> onMatch(String url) async {
///     onCall(url.replaceFirst('tel:', ''));
///     return NavigationActionPolicy.CANCEL;
///   }
/// }
/// ```
///
/// **Example – intercept a transaction success deep-link:**
/// ```dart
/// class TransactionSuccessAction implements BankNavigationAction {
///   const TransactionSuccessAction({required this.onSuccess});
///   final VoidCallback onSuccess;
///
///   @override
///   bool matches(String url) => url.contains('/transaction/success');
///
///   @override
///   Future<NavigationActionPolicy> onMatch(String url) async {
///     onSuccess();
///     return NavigationActionPolicy.CANCEL;
///   }
/// }
/// ```
abstract interface class BankNavigationAction {
  /// Returns true if this action should handle [url].
  bool matches(String url);

  /// Called when [matches] is true. Performs any side-effect and returns the
  /// [NavigationActionPolicy] to apply (typically CANCEL after handling).
  Future<NavigationActionPolicy> onMatch(String url);
}

/// Orchestrates a chain of [BankNavigationAction]s.
///
/// Receives the full `InAppWebView` navigation context plus the `onEvent` 
/// callback so it can dispatch [WebViewEvent]s if needed. It extracts the URL
/// and delegates each action's logic to the action itself, keeping this class
/// as a pure coordinator (SRP + OCP: add actions without touching this class).
///
/// Inject a custom implementation of this class into [WebViewConfig] to
/// override the default chain-of-responsibility behaviour (DIP).
class WebViewNavigationDelegate {
  const WebViewNavigationDelegate({
    this.actions = const [],
  });

  /// The ordered list of actions to evaluate on each navigation request.
  final List<BankNavigationAction> actions;

  /// Evaluates [actions] in order and returns the first policy from a matching
  /// action, or null if no action claims the URL (allowing the engine to fall
  /// through to the allow-list in [BankingWebView]).
  Future<NavigationActionPolicy?> call(
    InAppWebViewController controller,
    NavigationAction navigationAction, {
    required void Function(WebViewEvent)? onEvent,
  }) async {
    final url = navigationAction.request.url?.toString() ?? '';
    for (final action in actions) {
      if (action.matches(url)) {
        return action.onMatch(url);
      }
    }
    return null;
  }
}
