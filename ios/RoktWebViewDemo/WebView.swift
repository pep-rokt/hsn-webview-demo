import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()

        // Register the JS → native message handler via a weak proxy
        // to avoid a retain cycle with WKUserContentController.
        let proxy = ScriptMessageProxy(handler: context.coordinator)
        config.userContentController.add(proxy, name: "roktMessageHandler")

        let webView = WKWebView(frame: .zero, configuration: config)
        if #available(iOS 16.4, *) { webView.isInspectable = true }

        // Pull-to-refresh reloads the page (and re-triggers GTM/Rokt)
        webView.scrollView.refreshControl = UIRefreshControl()
        webView.scrollView.refreshControl?.addTarget(
            context.coordinator,
            action: #selector(Coordinator.handleRefresh(_:)),
            for: .valueChanged
        )

        // Keep a reference so the coordinator can clean up on deinit
        context.coordinator.webView = webView

        // Load the local confirmation page from the app bundle
        if let htmlURL = Bundle.main.url(forResource: "confirmation", withExtension: "html") {
            webView.loadFileURL(
                htmlURL,
                allowingReadAccessTo: htmlURL.deletingLastPathComponent()
            )
        }

        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    // MARK: - Coordinator

    class Coordinator: NSObject, WKScriptMessageHandler {
        weak var webView: WKWebView?

        func userContentController(
            _ userContentController: WKUserContentController,
            didReceive message: WKScriptMessage
        ) {
            guard message.name == "roktMessageHandler",
                  let urlString = message.body as? String,
                  let url = URL(string: urlString) else {
                return
            }

            // Open the intercepted Rokt link in the user's default browser (Safari)
            UIApplication.shared.open(url)
        }

        @objc func handleRefresh(_ sender: UIRefreshControl) {
            webView?.reload()
            sender.endRefreshing()
        }

        deinit {
            webView?.configuration.userContentController
                .removeScriptMessageHandler(forName: "roktMessageHandler")
        }
    }
}
