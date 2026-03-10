package com.rokt.webviewdemo

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.util.Log
import android.webkit.JavascriptInterface

/**
 * JavaScript bridge exposed to the WebView as `window.roktLinkOpener`.
 *
 * The Rokt SDK fires a LINK_NAVIGATION_REQUEST event when a user taps a link
 * (because overrideLinkNavigation is enabled). The GTM custom code subscribes
 * to that event and calls `window.roktLinkOpener.openLink(url)` to hand the
 * URL to the native layer, which opens it in the device's default browser.
 */
class WebViewBridge(private val context: Context) {

    @JavascriptInterface
    fun openLink(url: String) {
        Log.d(TAG, "Opening URL in browser: $url")
        try {
            val intent = Intent(Intent.ACTION_VIEW, Uri.parse(url))
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            context.startActivity(intent)
        } catch (e: Exception) {
            Log.e(TAG, "Failed to open URL: $url", e)
        }
    }

    companion object {
        private const val TAG = "WebViewBridge"
    }
}
