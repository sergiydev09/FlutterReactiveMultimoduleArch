# WebView Library (`webview_lib`)

A security-focused WebView infrastructure for the banking application based on `webview_flutter`.

---

## Core Components

### `BankingWebView`

The primary widget for displaying web content. Integrates SSL pinning, cookie injection, domain enforcement, and a bidirectional JavaScript bridge.

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
    sslPinHashes: ['base64EncodedSha256OfSpki=='],
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
| `supportMultipleWindows` | `bool` | `false` | Allows pop-up windows (`target="_blank"`, `window.open`). |
| `clearCookiesOnDispose` | `bool` | `true` | Deletes session cookies and clears cache on widget disposal. |
| `userAgent` | `String?` | `null` | Custom user-agent string. |
| `navigationDelegate` | `WebViewNavigationDelegate` | empty delegate | Chain-of-responsibility handler for non-browser URL schemes. |
| `cookieJar` | `CookieJar?` | `null` | Dio `CookieJar` to sync into the native cookie store during `initState`, before the first request fires. No-op for `WebViewHtmlSource`. |
| `sslPinHashes` | `List<String>` | `[]` | SHA-256 hashes (base64) of trusted certificates or SPKI keys. Empty falls back to OS certificate validation. |

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

### Sending data to the web page

Provide `initialData` — it is called once after `onPageFinished` and the result is sent to the page as `window.onFlutterData(jsonString)`.

**Flutter:**
```dart
BankingWebView(
  // ...
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

The page posts a JSON-serialised message to `window.FlutterBridge`. Flutter receives a `WebViewCustomEvent`.

**JavaScript:**
```js
window.FlutterBridge.postMessage(JSON.stringify({
  action: 'process_payment',
  data: { amount: 50.0, currency: 'EUR' }
}));
```

**Flutter:**
```dart
onEvent: (event) {
  if (event is WebViewCustomEvent && event.name == 'process_payment') {
    final amount = event.data?['amount'];
    // trigger Flutter logic
  }
}
```

> JavaScript must be enabled (`enableJavaScript: true`) for the bridge to function.

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

## SSL Pinning

SSL pinning is configured via `WebViewConfig.sslPinHashes` — a flat list of SHA-256 hashes shared with `EnvironmentConfig.certificatePinHashes`. The validation logic lives entirely in `CertificatePinning.validatePins` (`package:common`) and is reused by both the WebView and the Dio `HttpClient`.

> **Platform limitation:** `webview_flutter` only surfaces certificate errors through `onSslAuthError`, which fires when the OS itself rejects the TLS handshake (e.g. self-signed or expired certificates). Connections to OS-trusted certificates — including those with valid CA chains that you might still want to pin — do **not** trigger `onSslAuthError`. For stricter pinning on production traffic, consider supplementing with Dio's `HttpClient` pinning (configured in `CertificatePinning`) which runs on every request.

### Rules

| Scenario | Behaviour |
| :--- | :--- |
| `sslPinHashes` is empty, no OS SSL error | ✅ Allowed |
| `sslPinHashes` is empty, OS SSL error detected | ❌ Blocked — `SECURITY_SSL_ERROR` |
| `sslPinHashes` non-empty, server provides no X.509 certificate | ❌ Blocked — `SECURITY_SSL_MISSING` |
| `sslPinHashes` non-empty, no hash matches | ❌ Blocked — `SECURITY_SSL_PINNING_FAILED` |
| `sslPinHashes` non-empty, at least one hash matches | ✅ Allowed |

### Pinning strategy — certificate hash only

Only **certificate hash pinning** is supported. `sslPinHashes` must contain SHA-256 fingerprints of the full DER-encoded X.509 certificate.

**How it works:** `PlatformSslPinning.handle` extracts `SslAuthError.certificate.data` (DER bytes of the leaf cert) and passes them to `CertificatePinning.validatePins`, which computes `sha256(DER)` and checks it against `sslPinHashes`.

> **SPKI (public-key) pinning is not implemented.** Neither `SslAuthError` nor `dart:io`'s `X509Certificate` exposes the SubjectPublicKeyInfo bytes in Dart, so no code path in this library computes an SPKI hash. Do not add SPKI hashes to `sslPinHashes` — they will never match and will always block the connection.

**Certificate pinning limitation:** a pinned cert hash must be updated in `sslPinHashes` (and a new app version released) on every certificate renewal, even if the server key pair doesn't change. Plan your certificate rotation accordingly.

### Usage

```dart
WebViewConfig(
  sslPinHashes: ['base64EncodedSha256OfDerCert=='],
)
```

Pass the same list from `EnvironmentConfig` to keep pinning consistent across the app:

```dart
WebViewConfig(
  sslPinHashes: environmentConfig.certificatePinHashes,
)
```

### Obtaining the certificate hash

```sh
openssl s_client -connect host:443 </dev/null 2>/dev/null \
  | openssl x509 -outform DER \
  | openssl dgst -sha256 -binary \
  | openssl base64
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
| `WebViewCloseEvent` | `window.close()` called | Pop the current screen |
| `WebViewNavigateEvent` | Successful allowed navigation | Analytics / breadcrumbs |
| `WebViewCustomEvent(name: 'OPEN_NEW_WINDOW')` | `target="_blank"` on an allowed domain | Open in-app browser |
| `WebViewCustomEvent(name: 'SECURITY_SSL_ERROR')` | OS SSL error, no pin configured | Alert user |
| `WebViewCustomEvent(name: 'SECURITY_SSL_MISSING')` | Pinned host provided no certificate | Alert user |
| `WebViewCustomEvent(name: 'SECURITY_SSL_PINNING_FAILED')` | None of the configured pins matched | Alert + log incident |

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
3. **Plan certificate rotation** — only certificate hash pinning is implemented. Every cert renewal requires updating `sslPinHashes` and shipping a new app version. Always include at least two hashes (current + next) to allow overlap during rotation.
4. **Always include at least two hashes** — one active, one for the next certificate — to avoid locking users out during rotation.
5. **Use `cookieJar`** — pass the shared Dio `CookieJar` rather than injecting cookies manually.
6. **`clearCookiesOnDispose: true`** (default) — protects the session when the user leaves the WebView screen.
