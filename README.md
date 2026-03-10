# HSN WebView — Rokt Integration Demo

Demo apps that load a Rokt placement inside a native WebView via Google Tag Manager. Link clicks within the placement are intercepted and opened in the device's default browser.

## Quick Start

1. Clone the repo:
   ```bash
   git clone git@github.com:pep-rokt/hsn-webview-demo.git
   cd hsn-webview-demo
   ```
2. Follow the setup guide for your platform:

| Platform | Directory      | README                      |
| -------- | -------------- | --------------------------- |
| iOS      | [`ios/`](ios/) | [iOS README](ios/README.md) |
| Android  | `android/`     | Coming soon                 |

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

Each platform demo subscribes to this event and forwards the URL to the native layer to open in the device browser. See the platform-specific README for implementation details.

## Project Structure

```
hsn-webview-demo/
├── gtm-custom-code.html           # Rokt SDK code delivered via GTM Custom HTML tag
├── README.md                      # This file
├── ios/                           # iOS demo (see ios/README.md)
└── android/                       # Android demo (coming soon)
```
