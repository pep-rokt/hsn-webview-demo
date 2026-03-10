import WebKit

/// Weak-delegate wrapper that breaks the retain cycle between
/// WKUserContentController and the actual WKScriptMessageHandler.
///
/// WKUserContentController retains its message handlers strongly.
/// Without this proxy, the Coordinator (handler) and WKWebView would
/// never be deallocated.
class ScriptMessageProxy: NSObject, WKScriptMessageHandler {
    weak var handler: WKScriptMessageHandler?

    init(handler: WKScriptMessageHandler) {
        self.handler = handler
        super.init()
    }

    func userContentController(
        _ userContentController: WKUserContentController,
        didReceive message: WKScriptMessage
    ) {
        handler?.userContentController(userContentController, didReceive: message)
    }
}
