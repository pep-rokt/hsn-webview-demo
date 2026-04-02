# iOS Demo

WebView app that loads the Rokt placement via GTM. Link clicks are intercepted and opened in the device's default browser.

**Default: UIWebView** (for apps with cookie-sync constraints). To switch to WKWebView, swap the view in `ContentView.swift`.

## Setup

**Prerequisites:** macOS with Xcode 15+

```bash
open RoktWebViewDemo.xcodeproj
```

Select a simulator, then **Cmd+R** to build and run. Pull down to refresh.

## Message Bridge

Both implementations intercept `LINK_NAVIGATION_REQUEST` from the Rokt SDK and forward the URL to the native layer to open in the default browser.

### UIWebView (default) — URL scheme interception

UIWebView has no JS-to-native message API, so links are forwarded via a custom `rokt-link://` URL scheme:

1. Native injects `window.roktLegacyWebView = true` after page load
2. GTM tag detects the flag and navigates to `rokt-link://<encoded-url>`
3. `shouldStartLoadWith` intercepts the scheme, decodes the URL, opens it via `UIApplication.shared.open()`

See `LegacyWebView.swift`.

### WKWebView (alternative) — message handler

WKWebView has a built-in `WKScriptMessageHandler` API:

1. Native registers a handler named `roktMessageHandler`
2. GTM tag calls `window.webkit.messageHandlers.roktMessageHandler.postMessage(url)`
3. Coordinator receives the message and opens the URL via `UIApplication.shared.open()`

See `WebView.swift` + `ScriptMessageProxy.swift`.

## Files

| File | Purpose |
|------|---------|
| `RoktWebViewDemo/LegacyWebView.swift` | UIWebView + URL scheme interception (default) |
| `RoktWebViewDemo/WebView.swift` | WKWebView + message handler (alternative) |
| `RoktWebViewDemo/ScriptMessageProxy.swift` | Prevents WKWebView retain cycle |
| `RoktWebViewDemo/ContentView.swift` | Toggle between UIWebView / WKWebView |
| `RoktWebViewDemo/confirmation.html` | Order confirmation page (loads GTM) |
| `RoktWebViewDemo/RoktWebViewDemoApp.swift` | App entry point |

## Debugging

Open Safari → **Settings → Advanced → Show features for web developers**. With the simulator running: **Develop → Simulator → confirmation.html**.
