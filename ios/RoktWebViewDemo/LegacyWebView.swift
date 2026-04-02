import SwiftUI
import UIKit

/// UIWebView alternative for apps that cannot migrate to WKWebView
/// (e.g. due to cookie-sync issues with NSHTTPCookieStorage).
///
/// Uses URL scheme interception since UIWebView has no WKScriptMessageHandler:
///   1. Native injects `window.roktLegacyWebView = true` after page load
///   2. GTM tag navigates to rokt-link://<encoded-url> on link click
///   3. shouldStartLoadWith intercepts the scheme and opens the URL in the default browser
struct LegacyWebView: UIViewRepresentable {

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> UIWebView {
        let webView = UIWebView()
        webView.delegate = context.coordinator
        context.coordinator.webView = webView

        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(
            context.coordinator,
            action: #selector(Coordinator.handleRefresh(_:)),
            for: .valueChanged
        )
        webView.scrollView.addSubview(refreshControl)
        context.coordinator.refreshControl = refreshControl

        if let htmlURL = Bundle.main.url(forResource: "confirmation", withExtension: "html") {
            webView.loadRequest(URLRequest(url: htmlURL))
        }

        return webView
    }

    func updateUIView(_ uiView: UIWebView, context: Context) {}

    class Coordinator: NSObject, UIWebViewDelegate {
        weak var webView: UIWebView?
        weak var refreshControl: UIRefreshControl?

        func webView(
            _ webView: UIWebView,
            shouldStartLoadWith request: URLRequest,
            navigationType: UIWebView.NavigationType
        ) -> Bool {
            guard let url = request.url else { return true }

            if url.scheme == "rokt-link" {
                let encoded = url.absoluteString.replacingOccurrences(of: "rokt-link://", with: "")
                if let decoded = encoded.removingPercentEncoding,
                   let targetURL = URL(string: decoded) ?? URLComponents(string: decoded)?.url {
                    UIApplication.shared.open(targetURL)
                }
                return false
            }

            return true
        }

        func webViewDidFinishLoad(_ webView: UIWebView) {
            webView.stringByEvaluatingJavaScript(from: "window.roktLegacyWebView = true;")
        }

        @objc func handleRefresh(_ sender: UIRefreshControl) {
            webView?.reload()
            sender.endRefreshing()
        }
    }
}
