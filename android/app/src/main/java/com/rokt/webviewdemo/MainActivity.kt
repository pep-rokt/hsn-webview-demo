package com.rokt.webviewdemo

import android.annotation.SuppressLint
import android.os.Bundle
import android.webkit.WebSettings
import android.webkit.WebView
import android.webkit.WebViewClient
import androidx.appcompat.app.AppCompatActivity
import com.rokt.webviewdemo.databinding.ActivityMainBinding

class MainActivity : AppCompatActivity() {

    private lateinit var binding: ActivityMainBinding
    private lateinit var webView: WebView

    @SuppressLint("SetJavaScriptEnabled")
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)

        webView = binding.webView

        // Configure WebView
        webView.settings.javaScriptEnabled = true
        webView.settings.domStorageEnabled = true
        webView.settings.mixedContentMode = WebSettings.MIXED_CONTENT_ALWAYS_ALLOW
        webView.webViewClient = WebViewClient()
        WebView.setWebContentsDebuggingEnabled(BuildConfig.DEBUG)

        // Register JS interface — accessible as window.roktLinkOpener in JavaScript
        webView.addJavascriptInterface(WebViewBridge(this), "roktLinkOpener")

        // Pull-to-refresh reloads the page (and re-triggers GTM/Rokt)
        binding.swipeRefresh.setOnRefreshListener {
            webView.reload()
            binding.swipeRefresh.isRefreshing = false
        }

        // Load the local confirmation page
        webView.loadUrl("file:///android_asset/confirmation.html")
    }

    @Deprecated("Use OnBackPressedCallback instead")
    override fun onBackPressed() {
        if (webView.canGoBack()) {
            webView.goBack()
        } else {
            @Suppress("DEPRECATION")
            super.onBackPressed()
        }
    }
}
