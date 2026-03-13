# WebView Library (`webview_lib`)

A robust, security-focused WebView infrastructure for the banking application based on `flutter_inappwebview`.

## Core Components

### `BankingWebView`
The primary widget for displaying web content. It integrates security policies, navigation interception, and a bidirectional JavaScript bridge.

```dart
BankingWebView(
  source: WebViewHtmlSource(htmlContent), // or WebViewUrlSource('https://...')
  config: WebViewConfig(
    enableJavaScript: true,
    allowedDomains: ['trusted-bank.com'],
  ),
  onEvent: (event) => print('Action from JS: ${event.name}'),
)
```

### `WebViewConfig`
Centralized configuration for the WebView.
- **`allowedDomains`**: (List<String>) Domains allowed for navigation. **Empty list allows all** (use with caution).
- **`enableJavaScript`**: (bool) Defaults to `false` for security.
- **`navigationDelegate`**: Orchestrates custom URL scheme handling.

### `WebViewSource`
Defines what content to load:
- **`WebViewUrlSource`**: Loads a remote URL with optional HTTP headers.
- **`WebViewHtmlSource`**: Loads a static HTML string with an optional base URL.

---

## Navigation Actions & Delegation

The library uses a delegation pattern to handle non-browser navigation (e.g., opening native apps).

### `WebViewNavigationDelegate`
Holds a list of `BankNavigationAction` implementations. When a navigation occurs, it iterates through them to see if any can handle the URL.

### Standard Navigation Actions
Include the following in your `WebViewConfig` to support native app launching:

```dart
WebViewConfig(
  navigationDelegate: WebViewNavigationDelegate(
    actions: [
      TelNavigationAction(),      // Handles tel:
      MailToNavigationAction(),   // Handles mailto:
      SmsNavigationAction(),      // Handles sms: and smsto:
      MapsNavigationAction(),     // Handles geo:, maps:, and comgooglemaps:
      AppStoreNavigationAction(),  // Handles market:, itms-apps:, etc.
    ],
  ),
)
```

---

## JavaScript Bridge

Bidirectional communication between Flutter and the web page.

### Sending data to Web
The `BankingWebView` calls `window.onFlutterData(jsonString)` in JS whenever the `initialData` or reactive updates are sent.

**Flutter Example:**
```dart
BankingWebView(
  // ...
  initialData: () async => {
    'user': {'name': 'John Doe', 'tier': 'Gold'},
    'preferences': {'darkMode': true},
  },
)
```

**JavaScript Example:**
```js
window.onFlutterData = function(payload) {
  const data = JSON.parse(payload);
  console.log('User name:', data.user.name);
};
```

### Receiving events from Web
The web page can send events to Flutter using the `FlutterBridge` handler.

**JavaScript Example:**
```js
function onPaymentClick() {
  window.flutter_inappwebview.callHandler('FlutterBridge', {
    action: 'process_payment',
    data: { amount: 50.0, currency: 'EUR' }
  });
}
```

**Flutter Example:**
```dart
onEvent: (event) {
  if (event.name == 'process_payment') {
    final amount = event.data?['amount'];
    // Trigger Flutter logic...
  }
}
```

---

## Cookie Management

Use `BankingCookieManager` to handle secure session cookies. This is handled separately from the configuration and should be called before loading the WebView.

### Injecting Secure Cookies
```dart
await BankingCookieManager.injectSecureCookies(
  url: 'https://api.banking-app.com',
  cookies: [
    BankingCookie(
      name: 'session_id',
      value: 'abc-123-xyz',
      domain: 'banking-app.com',
    ),
  ],
);
```

### Clearing Session
```dart
// Deletes cookies for the URL and clears the WebView cache
await BankingCookieManager.clearBankingSession('https://api.banking-app.com');
```

---

## Advanced Security

### SSL Strictness
By default, `BankingWebView` implements a **Strict SSL Layer**. Any certificate challenge that is not trusted by the OS is automatically cancelled to prevent MITM attacks. 

Whenever an SSL error occurs, a `SECURITY_SSL_ERROR` event is emitted via the `onEvent` callback.

### Domain Enforcement
Navigation to any domain not in the `allowedDomains` list is cancelled. If a link with `target="_blank"` or `window.open()` is clicked, it will only open if the domain is allowed, otherwise it's blocked.

---

## Lifecycle & Custom Events

The library emits several built-in events that you can listen to in the `onEvent` callback:

| Event Class | Condition | Typical Action |
| :--- | :--- | :--- |
| `WebViewSessionExpiredEvent` | HTTP 401 received | Redirect to Login |
| `WebViewNavigateEvent` | Successful navigation | Update breadcrumbs / Analytics |
| `WebViewCloseEvent` | `window.close()` called | Close the current screen |
| `SECURITY_SSL_ERROR` | Certificate trust failed | Alert user of insecure connection |

**Example: Handling Session Expiry**
```dart
onEvent: (event) {
  if (event is WebViewSessionExpiredEvent) {
    // Show session expired dialog or logout
    context.read<AuthBloc>().add(LogoutRequested());
  }
}
```

---

## Platform-Specific Setup (CRITICAL)

To ensure `url_launcher` can open external apps, you **must** configure package visibility.

### Android (`AndroidManifest.xml`)
Add the following inside the `<queries>` block:
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
Add the `LSApplicationQueriesSchemes` key:
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
1. **Prefer `const` Configs**: `WebViewConfig` and `WebViewNavigationDelegate` support `const` for performance.
2. **Restrict Domains**: Always populate `allowedDomains` in production.
3. **Disable JS if possible**: Keep `enableJavaScript` as `false` unless the content requires it.
4. **Cookie Hygiene**: Use `clearCookiesOnDispose` (enabled by default) to protect user sessions.
