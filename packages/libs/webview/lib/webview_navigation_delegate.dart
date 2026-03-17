/// Library-owned navigation policy returned by [BankNavigationAction.onMatch].
///
/// Using this instead of the framework's `NavigationDecision` keeps
/// action implementations — and [WebViewNavigationDelegate] itself — free of
/// `webview_flutter`-specific dependencies (DIP). `BankingWebView` maps it to
/// `NavigationDecision` internally when wiring the `NavigationDelegate`.
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
/// They depend on this interface (DIP) and never on `webview_flutter` internals.
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
/// Evaluates each action against the given URL in order and returns the first
/// matching policy, or null if no action claims the URL. Keeping this class
/// free of framework types means actions can be unit-tested without a WebView.
///
/// Inject a custom implementation into `WebViewConfig` to override the default
/// chain-of-responsibility behaviour (DIP).
class WebViewNavigationDelegate {
  const WebViewNavigationDelegate({
    this.actions = const [],
  });

  /// The ordered list of actions to evaluate on each navigation request.
  final List<BankNavigationAction> actions;

  /// Evaluates [actions] in order against [url] and returns the first matching
  /// [WebViewNavigationPolicy], or null if no action claims the URL.
  ///
  /// The caller (`BankingWebView`) is responsible for mapping the returned
  /// policy to the framework's `NavigationDecision`.
  Future<WebViewNavigationPolicy?> call(String url) async {
    for (final action in actions) {
      if (action.matches(url)) {
        return action.onMatch(url);
      }
    }
    return null;
  }
}
