import 'package:flutter_inappwebview/flutter_inappwebview.dart';

/// Library-owned navigation policy returned by [BankNavigationAction.onMatch].
///
/// Using this instead of the framework's [NavigationActionPolicy] keeps
/// action implementations free of InAppWebView-specific dependencies (DIP).
/// [WebViewNavigationDelegate] maps it to [NavigationActionPolicy] internally.
enum WebViewNavigationPolicy {
  /// Allow the navigation to proceed.
  allow,

  /// Cancel the navigation (e.g. after handling it natively).
  cancel,
}

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
///   Future<WebViewNavigationPolicy> onMatch(String url) async {
///     onCall(url.replaceFirst('tel:', ''));
///     return WebViewNavigationPolicy.cancel;
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
///   Future<WebViewNavigationPolicy> onMatch(String url) async {
///     onSuccess();
///     return WebViewNavigationPolicy.cancel;
///   }
/// }
/// ```
abstract interface class BankNavigationAction {
  /// Returns true if this action should handle [url].
  bool matches(String url);

  /// Called when [matches] is true. Performs any side-effect and returns the
  /// [WebViewNavigationPolicy] to apply (typically [WebViewNavigationPolicy.cancel]
  /// after handling).
  Future<WebViewNavigationPolicy> onMatch(String url);
}

/// Orchestrates a chain of [BankNavigationAction]s.
///
/// Extracts the URL and delegates each action's logic to the action itself,
/// keeping this class as a pure coordinator (SRP + OCP: add actions without
/// touching this class).
///
/// Inject a custom implementation of this class into [WebViewConfig] to
/// override the default chain-of-responsibility behaviour (DIP).
class WebViewNavigationDelegate {
  const WebViewNavigationDelegate({
    this.actions = const [],
  });

  /// The ordered list of actions to evaluate on each navigation request.
  final List<BankNavigationAction> actions;

  /// Evaluates [actions] in order and returns the first matching policy mapped
  /// to [NavigationActionPolicy], or null if no action claims the URL.
  Future<NavigationActionPolicy?> call(
    InAppWebViewController controller,
    NavigationAction navigationAction,
  ) async {
    final url = navigationAction.request.url?.toString() ?? '';
    for (final action in actions) {
      if (action.matches(url)) {
        final policy = await action.onMatch(url);
        return switch (policy) {
          WebViewNavigationPolicy.allow => NavigationActionPolicy.ALLOW,
          WebViewNavigationPolicy.cancel => NavigationActionPolicy.CANCEL,
        };
      }
    }
    return null;
  }
}
