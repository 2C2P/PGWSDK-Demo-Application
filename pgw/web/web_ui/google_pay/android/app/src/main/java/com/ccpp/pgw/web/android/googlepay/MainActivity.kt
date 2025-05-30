package com.ccpp.pgw.web.android.googlepay

import android.annotation.SuppressLint
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import android.view.ViewGroup
import android.webkit.WebSettings
import android.webkit.WebView
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.viewinterop.AndroidView
import androidx.webkit.WebSettingsCompat
import androidx.webkit.WebViewCompat
import androidx.webkit.WebViewFeature
import com.ccpp.pgw.web.android.googlepay.ui.theme._2C2PWebUIXGooglePayApplicationTheme

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            _2C2PWebUIXGooglePayApplicationTheme {
                Scaffold(modifier = Modifier.fillMaxSize()) { innerPadding ->
                    GooglePay(
                        modifier = Modifier.padding(innerPadding)
                    )
                }
            }
        }
    }
}

@Composable
fun GooglePay(modifier: Modifier = Modifier) {
    val context = LocalContext.current
    Column(
        modifier = modifier
            .background(Color.White)
            .padding(top = 15.dp)
    ) {
        var url by remember { mutableStateOf("https://sandbox-pgw-ui.2c2p.com/payment/4.1/#/token/kSAops9Zwhos8hSTSeLTUUbpWqqPoQ9ofgEIonIb5NMY82XhFgQppTAwaP5EmUWIh329XeP6jTh5LV2uDC%2fu7EOJsOYWP8XbwyNHDS6Pc0HGU7Fg0fFFE9U1%2b%2fki4FjW?showDetails=true") }
        OutlinedTextField(
            modifier = Modifier
                .background(Color.White)
                .fillMaxWidth()
                .padding(horizontal = 15.dp),
            value = url,
            onValueChange = {
                val isValidUrl = android.util.Patterns.WEB_URL.matcher(it).matches()
                if (isValidUrl) {
                    url = it
                }
            },
            label = {
                Text("Web UI Url: ")
            },
            maxLines = 3
        )
        Column(
            modifier = Modifier
                .padding(horizontal = 25.dp, vertical = 15.dp)
        ) {
            Text("Android WebView Version: ${webViewVersion(context)}")
            Text("Google Pay Service Version: ${googlePayServiceVersion(context)}")
            Text("WebViewFeature.isFeatureSupported: ${WebViewFeature.isFeatureSupported(WebViewFeature.PAYMENT_REQUEST)}")
        }
        WebViewComponent(modifier, context, url)
    }
}

// Reference: https://developers.google.com/pay/api/android/guides/recipes/using-android-webview
//            https://developers.google.com/pay/api/android/guides/test-and-deploy/publish-your-integration
@SuppressLint("SetJavaScriptEnabled")
@Composable
fun WebViewComponent(modifier: Modifier, context: Context, url: String) {
    AndroidView(
        factory = {
            WebView(context).apply {
                layoutParams = ViewGroup.LayoutParams(
                    ViewGroup.LayoutParams.MATCH_PARENT,
                    ViewGroup.LayoutParams.MATCH_PARENT
                )

                //Optional
                settings.builtInZoomControls = true
                settings.setSupportZoom(true)
                settings.loadWithOverviewMode = true
                settings.useWideViewPort = true
                settings.cacheMode = WebSettings.LOAD_NO_CACHE

                //Mandatory
                settings.javaScriptEnabled = true
                settings.domStorageEnabled = true //Some bank page required. eg: am bank

                //IMPORTANT: User device requirements
                //           - Google Play services version 25.18.30 or higher
                //           - Android WebView component and Chrome version 137 or higher (currently in Beta)
                if (WebViewFeature.isFeatureSupported(WebViewFeature.PAYMENT_REQUEST)) {
                    WebSettingsCompat.setPaymentRequestEnabled(settings, true)
                }
                loadUrl(url)
            }
        },
        update = {
            if (it.url != url) {
                it.loadUrl(url)
            }
        },
        modifier = modifier.fillMaxSize()
    )
}

fun webViewVersion(context: Context): String {
    return try {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            WebViewCompat.getCurrentWebViewPackage(context)?.versionName ?: "Unknown"
        } else {
            val webViewPackageName = "com.google.android.webview"
            context.packageManager.getPackageInfo(webViewPackageName, 0).versionName ?: "Unknown"
        }
    } catch (e: Exception) {
        e.printStackTrace()
        "Unknown"
    }
}

fun googlePayServiceVersion(context: Context): String {
    return try {
        val googlePayPackageName = "com.google.android.gms"
        val packageInfo = context.packageManager.getPackageInfo(googlePayPackageName, 0)
        packageInfo?.versionName ?: "Unknown"
    } catch (e: PackageManager.NameNotFoundException) {
        "Not Installed"
    } catch (e: Exception) {
        e.printStackTrace()
        "Unknown"
    }
}

@Preview(showBackground = true)
@Composable
fun GooglePayPreview() {
    _2C2PWebUIXGooglePayApplicationTheme {
        GooglePay()
    }
}