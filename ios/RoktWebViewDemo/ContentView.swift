import SwiftUI

struct ContentView: View {
    var body: some View {
        // Default: UIWebView (for apps with cookie-sync constraints)
        LegacyWebView()
            .ignoresSafeArea(edges: .bottom)

        // Alternative: WKWebView (recommended for new apps without cookie-sync constraints)
        // Swap the line above with the one below to use WKWebView instead:
        //
        // WebView()
        //     .ignoresSafeArea(edges: .bottom)
    }
}
