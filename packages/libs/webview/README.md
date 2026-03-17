# WebView Library (`webview_lib`)

A security-focused WebView infrastructure for the banking application based on `webview_flutter`.

---

## Core Components

### `BankingWebView`

The primary widget for displaying web content. Integrates cookie injection, domain enforcement, and a bidirectional JavaScript bridge.

```dart
BankingWebView(
  source: WebViewUrlSource(
    'https://banking-app.com/payments',
    headers: {'X-App-Version': '1.0.0'},
  ),
  config: WebViewConfig(
    enableJavaScript: true,
    allowedDomains: ['banking-app.com'],
    cookieJar: ref.read(cookieJarProvider),
    navigationDelegate: WebViewNavigationDelegate(
      actions: [TelNavigationAction(), MailToNavigationAction()],
    ),
  ),
  onEvent: (event) {
    if (event is WebViewSessionExpiredEvent) {
      context.go('/login');
    }
  },
  initialData: () async => {'user': 'Juan', 'tier': 'Gold'},
)
```

---

### `WebViewConfig`

Centralised, immutable configuration passed to `BankingWebView`.

| Field | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `allowedDomains` | `List<String>` | `['banking-app.com', ...]` | Domains the WebView may navigate to. Empty list allows all — **avoid in production**. |
| `enableJavaScript` | `bool` | `false` | Enables JavaScript. Disable unless the content requires it. |
| `enableZoom` | `bool` | `false` | Enables pinch-to-zoom. |
| `supportMultipleWindows` | `bool` | `false` | Allows pop-up windows. |
| `clearCookiesOnDispose` | `bool` | `true` | Deletes session cookies and clears cache on widget disposal. |
| `userAgent` | `String?` | `null` | Custom user-agent string. |
| `navigationDelegate` | `WebViewNavigationDelegate` | empty delegate | Chain-of-responsibility handler for non-browser URL schemes. |
| `jsActions` | `List<JsAction>` | `defaultJsActions` | Actions that inject JS and/or handle incoming bridge messages. See [JavaScript Actions](#javascript-actions). |
| `cookieJar` | `CookieJar?` | `null` | Dio `CookieJar` to sync into the native cookie store during `initState`, before the first request fires. No-op for `WebViewHtmlSource`. |

---

### `WebViewSource`

Defines what content to load:

- **`WebViewUrlSource(url, {headers})`** — loads a remote URL with optional HTTP headers.
- **`WebViewHtmlSource(html, {baseUrl})`** — loads a static HTML string with an optional base URL.

---

## Navigation Actions & Delegation

### `BankNavigationAction`

Interface for intercepting navigation. Implement two methods:

```dart
class TransactionSuccessAction implements BankNavigationAction {
  const TransactionSuccessAction({required this.onSuccess});
  final VoidCallback onSuccess;

  @override
  bool matches(String url) => url.contains('/transaction/success');

  @override
  Future<WebViewNavigationPolicy> onMatch(String url) async {
    onSuccess();
    return WebViewNavigationPolicy.cancel; // stop WebView from navigating
  }
}
```

`WebViewNavigationPolicy.allow` lets the WebView proceed; `.cancel` stops it (use after handling the URL natively).

### `WebViewNavigationDelegate`

Holds an ordered list of `BankNavigationAction`s. The first matching action wins (chain-of-responsibility). If no action matches, the domain allow-list is checked next.

### Built-in Navigation Actions

| Class | Schemes handled |
| :--- | :--- |
| `TelNavigationAction` | `tel:` |
| `MailToNavigationAction` | `mailto:` |
| `SmsNavigationAction` | `sms:`, `smsto:` |
| `MapsNavigationAction` | `geo:`, `maps:`, `comgooglemaps:` (falls back to Apple Maps) |
| `AppStoreNavigationAction` | `market:`, `play:`, `itms-apps:`, `itms:` |

All actions accept an optional `launcher` parameter for testing.

```dart
WebViewConfig(
  navigationDelegate: WebViewNavigationDelegate(
    actions: [
      TelNavigationAction(),
      MailToNavigationAction(),
      SmsNavigationAction(),
      MapsNavigationAction(),
      AppStoreNavigationAction(),
    ],
  ),
)
```

---

## JavaScript Bridge

The web page is expected to be **Flutter-aware**: it communicates with Flutter by posting messages directly to `window.FlutterBridge` rather than relying on injected shims.

### Architecture

Communication is bidirectional:

```
Flutter → Web   via script injection  (JsAction.script, run on every page load)
Web → Flutter   via bridge messages   (window.FlutterBridge.postMessage → JsAction.handleBridgeMessage)
```

### Sending data to the web page

Provide `initialData` — called once after `onPageFinished`, result sent as `window.onFlutterData(jsonString)`.

**Flutter:**
```dart
BankingWebView(
  initialData: () async => {
    'user': {'name': 'Juan García', 'tier': 'Gold'},
    'preferences': {'darkMode': true},
  },
)
```

**JavaScript:**
```js
window.onFlutterData = function(payload) {
  const data = JSON.parse(payload);
  console.log('User:', data.user.name);
};
```

### Receiving events from the web page

The page posts a JSON-serialised message to `window.FlutterBridge`:

**JavaScript:**
```js
window.FlutterBridge.postMessage(JSON.stringify({
  action: 'CLOSE',
  data: null
}));

window.FlutterBridge.postMessage(JSON.stringify({
  action: 'process_payment',
  data: { amount: 50.0, currency: 'EUR' }
}));
```

**Flutter:**
```dart
onEvent: (event) {
  switch (event) {
    case WebViewCloseEvent():
      Navigator.of(context).pop();
    case WebViewCustomEvent(:final name, :final data):
      _handleBridgeEvent(name, data);
    // ...
  }
}
```

> JavaScript must be enabled (`enableJavaScript: true`) for the bridge to function.

---

## JavaScript Actions

`JsAction` is the extension point for both script injection and bridge message handling. Each action controls two independent concerns:

| Member | Purpose | When to return `null` |
| :--- | :--- | :--- |
| `script` | JS injected after every page load | The page is Flutter-aware and calls the bridge directly — no shim needed |
| `handleBridgeMessage` | Maps an incoming bridge `action` to a typed `WebViewEvent` | This action doesn't own that `action` name |

### Default actions (`defaultJsActions`)

| Class | Injects script | Handles bridge message |
| :--- | :--- | :--- |
| `WindowCloseJsAction` | No | `"CLOSE"` → `WebViewCloseEvent` |
| `WindowOpenJsAction` | No | `"OPEN_NEW_WINDOW"` → `WebViewCustomEvent` |
| `BlankTargetLinksJsAction` | Yes — removes `target="_blank"` from links | No |

`WindowCloseJsAction` and `WindowOpenJsAction` have no script because the web page calls the bridge directly. `BlankTargetLinksJsAction` only needs injection (DOM manipulation, no callback).

### Adding custom actions

```dart
final class DeepLinkJsAction implements JsAction {
  const DeepLinkJsAction();

  // No injection needed — the page calls the bridge directly.
  @override
  String? get script => null;

  @override
  WebViewEvent? handleBridgeMessage(String action, Map<String, dynamic>? data) {
    if (action == 'DEEP_LINK') return WebViewCustomEvent(name: action, data: data);
    return null;
  }
}
```

Register it in the config:

```dart
WebViewConfig(
  jsActions: [
    ...defaultJsActions,
    const DeepLinkJsAction(),
  ],
)
```

If an incoming bridge message is not handled by any registered action, it is logged and discarded.

---

## SSL Errors

SSL errors are handled at the OS level. When the OS detects a TLS problem (expired certificate, untrusted CA, hostname mismatch):

- **Debug mode** — the connection is allowed to proceed so development against local or self-signed servers is not blocked.
- **Release / profile mode** — the connection is cancelled immediately.

No configuration is required. There is no pin hash list.

---

## Cookie Management

`BankingCookieManager` is the anti-corruption layer between Dio's `CookieJar` and the WebView's native cookie store.

### Automatic injection via `WebViewConfig.cookieJar`

The recommended approach. Pass the shared `CookieJar` (from `CommonProviders.cookieJar`) in the config. Cookies are injected automatically during `initState`, before the first request fires.

```dart
WebViewConfig(
  cookieJar: ref.read(cookieJarProvider),
)
```

### Manual injection

Use `BankingCookieManager` directly if you need finer control:

```dart
final manager = BankingCookieManager();

// Sync Dio cookies into the WebView for a given URL
await manager.injectFromCookieJar(
  url: 'https://banking-app.com',
  cookieJar: ref.read(cookieJarProvider),
);

// Clear session cookies for a specific URL
await manager.clearBankingSession('https://banking-app.com');

// Nuclear option — wipe all cookies and cache
await manager.clearAllWebData();
```

> **Note:** `webview_flutter`'s `WebViewCookie` does not support `httpOnly` or `sameSite` attributes. These must be enforced by the server. `BankingCookieManager` sets `name`, `value`, `domain`, and `path` only.

### Testing

Inject a fake `WebViewCookieManager` to avoid touching the native layer:

```dart
final manager = BankingCookieManager(cookieManager: fakeCookieManager);
```

---

## Events

`onEvent` receives typed `WebViewEvent` values. Use exhaustive pattern matching:

```dart
onEvent: (event) {
  switch (event) {
    case WebViewSessionExpiredEvent():
      context.go('/login');
    case WebViewCloseEvent():
      Navigator.of(context).pop();
    case WebViewNavigateEvent(:final url):
      analytics.logPageView(url);
    case WebViewCustomEvent(:final name, :final data):
      _handleBridgeEvent(name, data);
  }
}
```

### Built-in events

| Event class | Trigger | Typical action |
| :--- | :--- | :--- |
| `WebViewSessionExpiredEvent` | HTTP 401 received | Redirect to login |
| `WebViewCloseEvent` | Page posts `action: "CLOSE"` via bridge | Pop the current screen |
| `WebViewNavigateEvent` | Successful allowed navigation | Analytics / breadcrumbs |
| `WebViewCustomEvent(name: 'OPEN_NEW_WINDOW')` | Page posts `action: "OPEN_NEW_WINDOW"` via bridge | Open in-app browser |

---

## Platform-Specific Setup

### Android (`AndroidManifest.xml`)

Required to launch external apps via `url_launcher`:

```xml
<queries>
    <intent><action android:name="android.intent.action.DIAL"/><data android:scheme="tel"/></intent>
    <intent><action android:name="android.intent.action.SENDTO"/><data android:scheme="mailto"/></intent>
    <intent><action android:name="android.intent.action.SENDTO"/><data android:scheme="sms"/></intent>
    <intent><action android:name="android.intent.action.SENDTO"/><data android:scheme="smsto"/></intent>
    <intent><action android:name="android.intent.action.VIEW"/><data android:scheme="geo"/></intent>
    <intent><action android:name="android.intent.action.VIEW"/><data android:scheme="market"/></intent>
</queries>
```

### iOS (`Info.plist`)

```xml
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>tel</string>
    <string>mailto</string>
    <string>sms</string>
    <string>maps</string>
    <string>comgooglemaps</string>
    <string>itms-apps</string>
    <string>itms</string>
</array>
```

---

## Security Best Practices

1. **Restrict domains** — always populate `allowedDomains` in staging and production.
2. **Disable JS unless required** — keep `enableJavaScript: false` for pure-content pages.
3. **Use `cookieJar`** — pass the shared Dio `CookieJar` rather than injecting cookies manually.
4. **`clearCookiesOnDispose: true`** (default) — protects the session when the user leaves the WebView screen.
