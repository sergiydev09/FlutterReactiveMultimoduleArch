# Migration: `flutter_inappwebview` → `webview_flutter`

> **Status:** ✅ Complete — all 7 iterations done

## Why

Replacing the third-party `flutter_inappwebview` with the official Google/Flutter `webview_flutter` package for long-term maintenance, better platform alignment, and first-party support guarantees.

The `webview_lib` package already has a full abstraction layer (`BankingWebView`, `WebViewConfig`, `BankingCookieManager`, `JsBridge`, `WebViewNavigationDelegate`) — only the implementation files need changing. Feature code and the public API are untouched.

---

## Key API Differences (verified via Context7 docs)

| Concern | `flutter_inappwebview` | `webview_flutter` |
|---|---|---|
| Widget | `InAppWebView(...)` with inline callbacks | `WebViewWidget(controller: ...)` |
| Controller creation | Via `onWebViewCreated` callback | Eager in `initState()` before load |
| Navigation callback | `shouldOverrideUrlLoading(controller, NavigationAction)` → `NavigationActionPolicy` | `NavigationDelegate.onNavigationRequest(NavigationRequest)` → `NavigationDecision` |
| Page start/finish | `onLoadStart` / `onLoadStop` | `onPageStarted` / `onPageFinished` |
| Progress | `onProgressChanged(controller, int)` | `onProgress(int)` |
| HTTP error | `onReceivedHttpError(controller, request, error)` | `onHttpError(HttpResponseError)` |
| JS channel register | `addJavaScriptHandler(handlerName, callback: List<dynamic>)` | `addJavaScriptChannel(name, onMessageReceived: JavaScriptMessage)` |
| JS execute | `callAsyncJavaScript(functionBody, arguments)` | `runJavaScript(String)` |
| Cookie manager | `CookieManager.instance()` — per-URL `deleteCookies(url)` | `WebViewCookieManager` — global `clearCookies()` only |
| Cookie attributes | `isSecure`, `isHttpOnly`, `sameSite` supported | `WebViewCookie(name, value, domain, path)` only — no `httpOnly`/`sameSite` |
| SSL pinning | `onReceivedServerTrustAuthRequest` → DER bytes via `x509Certificate` | No Dart API — platform channel required |
| `window.close()` | Native `onCloseWindow` callback | JS injection: `window.close = () => channel.postMessage(...)` |
| `window.open()` | Native `onCreateWindow` callback | JS injection: `window.open = () => channel.postMessage(...)` |
| Inspectable (devtools) | `InAppWebViewSettings.isInspectable` | `WebKitWebViewController.setInspectable(bool)` (iOS only) |

### Important findings that affect the migration

**`cookie_jar` must stay** in `pubspec.yaml` — `WebViewConfig.cookieJar` and `BankingCookieManager.injectFromCookieJar` still use it. The original analysis incorrectly removed it.

**`BankingCookieManager._clearCache` breaks** — `InAppWebViewController.clearAllCache` is static; `controller.clearCache()` is an instance method. Fix: move `clearCache()` call out of `BankingCookieManager` into `BankingWebView.dispose()`.

**SSL pinning DER bytes unavailable in Dart** — `CertificatePinning.validatePins` takes `List<int>? certDerBytes/spkiDerBytes`. Neither `webview_flutter_android` nor `webview_flutter_wkwebview` expose raw DER bytes in their Dart APIs. Requires a native Method Channel to extract cert bytes and return them to Dart, so `CertificatePinning.validatePins` can still be called.

**JS injections re-run on every page load** — `window.close`, `window.open`, and `target="_blank"` JS overrides are cleared on each navigation. They must be re-injected in `onPageFinished`, not just once in `onWebViewCreated`.

**`addJavaScriptChannel` must be called before `loadRequest()`** — register the bridge channel on the controller before triggering any load.

**JS call site changes** — web pages must change from `window.flutter_inappwebview.callHandler('FlutterBridge', data)` to `window.FlutterBridge.postMessage(JSON.stringify(data))`.

---

## Iterations

| # | Scope | File(s) | Status |
|---|---|---|---|
| 1 | Swap library in pubspec files | `pubspec.yaml`, `webview/pubspec.yaml` | ✅ Done |
| 2 | Update `webview_source.dart` | `webview_source.dart` | ✅ Done |
| 3 | Update `webview_navigation_delegate.dart` | `webview_navigation_delegate.dart` | ✅ Done |
| 4 | Update `js_bridge.dart` | `js_bridge.dart` | ✅ Done |
| 5 | Update `webview_cookie_manager.dart` | `webview_cookie_manager.dart` | ✅ Done |
| 6 | Rewrite `banking_webview.dart` | `banking_webview.dart` | ✅ Done |
| 7 | SSL pinning via platform channels | `platform_ssl_pinning.dart` (new) | ✅ Done |

---

## Iteration Detail

### ✅ Iteration 1 — Swap the library

**Files changed:**
- [`pubspec.yaml`](../../pubspec.yaml) (root workspace)
- [`packages/libs/webview/pubspec.yaml`](pubspec.yaml)

**What changed:**
- Removed `flutter_inappwebview: ^6.1.5`
- Added `webview_flutter: ^4.13.0`, `webview_flutter_android: ^4.3.0`, `webview_flutter_wkwebview: ^3.18.1`
- Kept `cookie_jar` (still needed by `WebViewConfig` and `BankingCookieManager`)
- Ran `melos bootstrap` — 18 packages resolved successfully

---

### ✅ Iteration 2 — `webview_source.dart`

**What changed:**
- Removed `import 'package:flutter_inappwebview/...'`
- Removed `toUrlRequest()` from `WebViewUrlSource` — loading now done via `controller.loadRequest(Uri.parse(url), headers: headers)` in `banking_webview.dart` (Iteration 6)
- Removed `toInitialData()` from `WebViewHtmlSource` — loading now done via `controller.loadHtmlString(html, baseUrl: baseUrl)` in `banking_webview.dart` (Iteration 6)
- Changed `WebViewHtmlSource.baseUrl` type: `WebUri?` → `String?`

---

### ✅ Iteration 3 — `webview_navigation_delegate.dart`

**What changed:**
- Replaced `import 'package:flutter_inappwebview/...'` with `package:webview_flutter/webview_flutter.dart`
- Changed `call()` signature: `(InAppWebViewController, NavigationAction)` → `(NavigationRequest)`
- Changed return type: `NavigationActionPolicy?` → `NavigationDecision?`
- Mapped internal policy: `.allow` → `NavigationDecision.navigate`, `.cancel` → `NavigationDecision.prevent`
- URL extraction: `navigationAction.request.url?.toString()` → `request.url`
- `BankNavigationAction` interface and `WebViewNavigationPolicy` enum are **unchanged** — feature-layer actions need no modifications

---

### ✅ Iteration 4 — `js_bridge.dart`

**What changed:**
- Replaced `import 'package:flutter_inappwebview/...'` with `package:webview_flutter/webview_flutter.dart`
- `register(InAppWebViewController)` → `Future<void> register(WebViewController)` — made async because `addJavaScriptChannel` returns `Future<void>`
- `addJavaScriptHandler(handlerName, callback: List<dynamic>)` → `addJavaScriptChannel(name, onMessageReceived: (msg) => ...)`
- `_handleMessage(List<dynamic> args)` → `void _handleMessage(String rawMessage)` — always a String now, no type-branching needed
- `sendToWeb(InAppWebViewController, data)` → `sendToWeb(WebViewController, data)` using `runJavaScript(jsonEncode(data))`
- Updated docstring: web JS must now call `window.FlutterBridge.postMessage(JSON.stringify(payload))` instead of `window.flutter_inappwebview.callHandler(...)`

---

### ✅ Iteration 5 — `webview_cookie_manager.dart`

**What changed:**
- Removed `import 'package:flutter_inappwebview/...'`, replaced with `package:webview_flutter/webview_flutter.dart`
- Replaced `CookieManager.instance()` with `WebViewCookieManager()` — injectable via constructor for testing
- Replaced `setCookie(url, name, ..., isHttpOnly, sameSite: STRICT)` with `setCookie(WebViewCookie(name, value, domain, path))` — `httpOnly` and `sameSite` are **not supported** by `WebViewCookie`; added doc warning that the server must enforce these via `Set-Cookie` headers
- Replaced `deleteCookies(url:)` with global `clearCookies()` in both `injectFromCookieJar` and `clearBankingSession` — added doc warning: clears all domains, not just the target URL
- Removed `_clearCache` entirely — `controller.clearCache()` is an instance method and is called directly in `BankingWebView.dispose()` (Iteration 6)

---

### ✅ Iteration 6 — `banking_webview.dart` (largest change)

**Architectural shift:**
```
Before: InAppWebView(inline callbacks, onWebViewCreated callback)
After:  WebViewController (created in initState) + WebViewWidget
```

**What will change:**

1. Add `late WebViewController _controller` initialized in `initState()` with this order:
   - `setJavaScriptMode` based on `config.enableJavaScript`
   - `setUserAgent(config.userAgent)` if set
   - `addJavaScriptChannel` for bridge (must be before `loadRequest`)
   - `setNavigationDelegate(NavigationDelegate(...))`
   - Cookie injection from `cookieJar` (before load)
   - `loadRequest(...)` or `loadHtmlString(...)` last

2. `NavigationDelegate` replaces all inline callbacks:
   - `onPageStarted` → `_isLoading = true`
   - `onPageFinished` → `_isLoading = false` + send `initialData` + re-inject JS overrides
   - `onProgress` → updates `_progress`
   - `onNavigationRequest` → calls `navigationDelegate(request)` + allow-list check → `NavigationDecision`
   - `onHttpError` → checks `statusCode == 401` → `WebViewSessionExpiredEvent`

3. JS injections in `onPageFinished` (must re-run each load, native callbacks no longer exist):
   - `window.close` override → posts to bridge → `WebViewCloseEvent`
   - `window.open` override → posts to bridge → `WebViewCustomEvent(name: 'OPEN_NEW_WINDOW')`
   - `target="_blank"` rewrite → navigates in-frame so `onNavigationRequest` intercepts

4. `dispose()`: call `_controller.clearCache()` if `config.clearCookiesOnDispose` (replaces `BankingCookieManager._clearCache`)

5. iOS inspectable: after controller init, check platform and call `setInspectable(kDebugMode)` on `WebKitWebViewController`

6. `build()`: `InAppWebView(...)` → `WebViewWidget(controller: _controller)`

---

### ✅ Iteration 7 — SSL Pinning via platform channels (new file)

**Original plan:** Custom Method Channel (native Swift + Kotlin) to extract DER bytes.

**Actual implementation (simpler):** `webview_flutter` 4.13+ already exposes DER bytes in Dart via `SslAuthError.certificate.data` (`Uint8List?`). No native code needed.

**What changed:**
- Created `platform_ssl_pinning.dart` with `PlatformSslPinning.handle(error, pinHashes, onEvent)` — a pure Dart class
- `AndroidSslAuthError.certificate.data` ← `X509Certificate.getEncoded()` (populated by the platform package)
- `WebKitSslAuthError.certificate.data` ← `SecCertificate` data from the trust chain (populated by the platform package)
- Added `onSslAuthError` to the `NavigationDelegate` in `banking_webview.dart`; calls `PlatformSslPinning.handle` via `unawaited`
- Exported `PlatformSslPinning` from `webview_lib.dart`

**Known limitation:** `NavigationDelegate.onSslAuthError` fires only when the OS already detected an SSL error. Connections with OS-trusted certs that don't match configured pins are **not** blocked from Dart. For strict SPKI pinning against OS-trusted certs, a native `URLAuthenticationChallenge` intercept is still required.

---

## Files Not Changed

| File | Reason |
|---|---|
| `webview_event.dart` | Pure Dart sealed classes, no framework dependency |
| `webview_config.dart` | No InAppWebView imports (only `cookie_jar` + internal) |
| `banking_default_navigation_actions.dart` | Implements `BankNavigationAction` interface only |
| `webview_lib.dart` | Barrel exports only |
| `features/accounts/…transaction_web_detail_page.dart` | Consumes public API — unchanged |
