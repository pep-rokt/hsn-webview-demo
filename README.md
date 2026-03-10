# HSN WebView — Rokt Integration Demo

Demo apps that load a Rokt placement inside a native WebView via Google Tag Manager. Link clicks within the placement are intercepted and opened in the device's default browser.

## Quick Start (iOS)

**Prerequisites:** macOS with [Xcode 15+](https://developer.apple.com/xcode/) installed

1. Clone the repo:
   ```bash
   git clone git@github.com:pep-rokt/hsn-webview-demo.git
   cd hsn-webview-demo
   ```
2. Open the Xcode project:
   ```bash
   open ios/RoktWebViewDemo.xcodeproj
   ```
3. In Xcode, select a simulator from the toolbar (e.g. **iPhone 16 Pro**)
4. Press **Cmd+R** to build and run

The app loads an order confirmation page with a Rokt placement. Tapping a link inside the placement opens it in Safari.

> If prompted for code signing, go to **Signing & Capabilities** and select your Apple ID (free accounts work for simulator builds).

## Platforms

- **[iOS](ios/)** — WKWebView + Swift, runs in Xcode Simulator

## GTM Tag

The WebView loads GTM container **GTM-MPN4J78**, which delivers the Rokt integration code via a Custom HTML tag (already published). A copy of that tag's code is included in [`gtm-custom-code.html`](gtm-custom-code.html) for reference.

Note: Rokt initialization and selectPlacements code has been combined inside a single tag for this demonstration but can also be split up based on HSN's use case.

## Rokt Link Navigation Override

By default, the Rokt SDK opens link clicks via `window.open()`, which in a WebView navigates away from the page. Two Rokt SDK features solve this:

**`overrideLinkNavigation: true`** — set during SDK init

- Suppresses the SDK's default `window.open()` behavior
- Instead, causes the SDK to emit a `LINK_NAVIGATION_REQUEST` event when user clicks a navigation link

**`LINK_NAVIGATION_REQUEST`** — [Rokt docs](https://docs.rokt.com/developers/integration-guides/web/messages/link-navigation-request-message/)

- Emitted on the `selection` object returned by `selectPlacements()` each time a user taps a link within a placement
- Payload contains `event.body.url` — the destination URL

Each platform demo subscribes to this event and forwards the URL to the native layer to open in the device browser. See the [iOS README](ios/README.md) for implementation details.

## Project Structure

```
hsn-webview-demo/
├── gtm-custom-code.html           # Rokt SDK code delivered via GTM Custom HTML tag
├── README.md                      # This file
├── ios/                           # iOS demo
│   ├── RoktWebViewDemo.xcodeproj  # Xcode project (open this)
│   ├── project.yml                # XcodeGen spec (for reference)
│   ├── README.md                  # iOS-specific docs
│   └── RoktWebViewDemo/           # Swift source files
└── android/                       # (coming soon)
```

## Configuration

| Setting | Value | File |
|---------|-------|------|
| GTM Container | `GTM-MPN4J78` | `ios/.../confirmation.html` |
| Rokt API Key | *(in GTM tag)* | `gtm-custom-code.html` |
| Development Mode | `true` | `gtm-custom-code.html` |

Set `isDevelopmentMode` to `false` in the GTM tag for production.

## Debugging

With the simulator running, you can inspect the WebView using Safari DevTools:

1. Open Safari → **Settings → Advanced → Show features for web developers**
2. **Develop → Simulator → confirmation.html**
3. Use the Console and Network tabs to verify GTM and Rokt SDK loaded
