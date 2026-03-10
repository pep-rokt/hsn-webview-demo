# iOS Demo

WKWebView app that loads the Rokt placement via GTM. Link clicks are intercepted and opened in Safari.

## Setup

**Prerequisites:** macOS with Xcode 15+

```bash
open RoktWebViewDemo.xcodeproj
```

In Xcode: select a simulator (e.g. iPhone 16 Pro) from the top toolbar, then **Cmd+R** to build and run. If prompted for code signing, select your Apple ID under Signing & Capabilities (free accounts work for simulator).

Pull down in the app to refresh and re-trigger the GTM tag.

## How the Message Bridge Works

The `LINK_NAVIGATION_REQUEST` URL is passed from JavaScript to native Swift via WKWebView's built-in message handler API:

```
Rokt SDK (JS)                    WKWebView (Swift)               Safari
─────────────                    ─────────────────               ──────
1. User taps a link
2. overrideLinkNavigation: true
   prevents default navigation
3. LINK_NAVIGATION_REQUEST
   event fires with the URL
4. JS handler calls:
   window.webkit.messageHandlers
     .roktMessageHandler          ──► 5. Coordinator receives
     .postMessage(url)                   WKScriptMessage
                                     6. Extracts URL string
                                     7. UIApplication.shared
                                        .open(url)              ──► 8. Opens in Safari
```

- **JS side** (`gtm-custom-code.html`): Subscribes to `LINK_NAVIGATION_REQUEST` and forwards the URL to the native layer via `window.webkit.messageHandlers.roktMessageHandler.postMessage(url)`.
- **Native side** (`WebView.swift`): A `WKScriptMessageHandler` registered under the name `roktMessageHandler` receives the message and opens the URL in Safari via `UIApplication.shared.open(url)`.

No third-party libraries are used — only Apple's native WebKit and UIKit frameworks.

## Files

| File | Purpose |
|------|---------|
| `project.yml` | XcodeGen spec — generates `.xcodeproj` |
| `RoktWebViewDemo/WebView.swift` | WKWebView setup + native message handler |
| `RoktWebViewDemo/confirmation.html` | Order confirmation page loaded in WebView (includes GTM) |
| `RoktWebViewDemo/ScriptMessageProxy.swift` | Prevents WKScriptMessageHandler retain cycle |
| `RoktWebViewDemo/ContentView.swift` | Main SwiftUI view |
| `RoktWebViewDemo/RoktWebViewDemoApp.swift` | App entry point |

## Debugging

Open Safari → **Settings → Advanced → Show features for web developers**. With the simulator running: **Develop → Simulator → confirmation.html**. Use the Console and Network tabs to verify GTM and Rokt SDK loaded.
