# Android Demo

WebView app that loads the Rokt placement via GTM. Link clicks are intercepted and opened in the device's default browser.

## Setup

**Prerequisites:** Android Studio Hedgehog (2023.1.1) or later

```
File → Open → select the android/ directory → wait for Gradle sync
```

Select an emulator from the toolbar (e.g. Pixel 8 API 35), then press **Shift+F10** (or the Run button) to build and run.

Pull down in the app to refresh and re-trigger the GTM tag.

## How the Message Bridge Works

The `LINK_NAVIGATION_REQUEST` URL is passed from JavaScript to native Kotlin via Android's JavascriptInterface API:

```
Rokt SDK (JS)                    WebView (Kotlin)               Browser
─────────────                    ────────────────               ───────
1. User taps a link
2. overrideLinkNavigation: true
   prevents default navigation
3. LINK_NAVIGATION_REQUEST
   event fires with the URL
4. JS handler calls:
   window.roktLinkOpener        ──► 5. WebViewBridge receives
     .openLink(url)                     @JavascriptInterface call
                                    6. Creates Intent(ACTION_VIEW, url)
                                    7. startActivity(intent)    ──► 8. Opens in browser
```

- **JS side** (`gtm-custom-code.html`): Subscribes to `LINK_NAVIGATION_REQUEST` and forwards the URL to the native layer via `window.roktLinkOpener.openLink(url)`.
- **Native side** (`WebViewBridge.kt`): A class with `@JavascriptInterface` annotation receives the call and opens the URL in the default browser via `Intent.ACTION_VIEW`.

No third-party libraries are used — only Android's native WebView and standard framework APIs.

## Files

| File | Purpose |
|------|---------|
| `app/.../MainActivity.kt` | WebView setup + pull-to-refresh |
| `app/.../WebViewBridge.kt` | JavaScript interface for URL handling |
| `app/.../res/layout/activity_main.xml` | Layout: SwipeRefreshLayout + WebView |
| `app/.../assets/confirmation.html` | Order confirmation page (includes GTM) |

## Debugging

1. With the app running on a device or emulator, open Chrome on your computer
2. Navigate to `chrome://inspect`
3. Find your device and click **inspect** next to the WebView
4. Use the Console and Network tabs to verify GTM and Rokt SDK loaded

WebView debugging is automatically enabled in debug builds.
