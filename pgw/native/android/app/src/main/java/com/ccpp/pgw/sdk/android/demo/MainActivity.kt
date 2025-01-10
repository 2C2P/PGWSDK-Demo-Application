package com.ccpp.pgw.sdk.android.demo

import android.annotation.SuppressLint
import android.app.Activity
import android.os.Bundle
import android.util.Log
import android.view.ViewGroup
import android.webkit.WebSettings
import android.webkit.WebView
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.Info
import androidx.compose.material.icons.filled.Settings
import androidx.compose.material.icons.outlined.Info
import androidx.compose.material.icons.outlined.ShoppingCart
import androidx.compose.material.icons.rounded.ShoppingCart
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Button
import androidx.compose.material3.FilledTonalButton
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.NavigationBar
import androidx.compose.material3.NavigationBarItem
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.viewinterop.AndroidView
import androidx.navigation.NavHostController
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import com.ccpp.pgw.sdk.android.callback.APIResponseCallback
import com.ccpp.pgw.sdk.android.callback.PGWWebViewClientCallback
import com.ccpp.pgw.sdk.android.callback.PGWWebViewTransactionStatusCallback
import com.ccpp.pgw.sdk.android.core.PGWSDK
import com.ccpp.pgw.sdk.android.core.authenticate.PGWWebViewClient
import com.ccpp.pgw.sdk.android.demo.MainActivity.Companion.paymentToken
import com.ccpp.pgw.sdk.android.demo.MainActivity.Companion.showAlertDialog
import com.ccpp.pgw.sdk.android.demo.apis.InfoApi
import com.ccpp.pgw.sdk.android.demo.apis.PaymentApi
import com.ccpp.pgw.sdk.android.demo.helper.StringHelper
import com.ccpp.pgw.sdk.android.demo.ui.theme.PGWSDKDemoApplicationTheme
import com.ccpp.pgw.sdk.android.enums.APIResponseCode
import com.ccpp.pgw.sdk.android.model.api.TransactionStatusRequest
import com.ccpp.pgw.sdk.android.model.api.TransactionStatusResponse
import com.google.android.material.dialog.MaterialAlertDialogBuilder
import java.lang.ref.WeakReference
import java.net.URLDecoder
import java.nio.charset.StandardCharsets
import java.util.Timer
import kotlin.concurrent.schedule
import kotlin.reflect.KFunction

/**
 * Created by DavidBilly PK on 23/12/24.
 */
class MainActivity : ComponentActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        activityReference = WeakReference(this)

        enableEdgeToEdge()
        setContent {
            PGWSDKDemoApplicationTheme {
                Scaffold(modifier = Modifier.fillMaxSize()) { innerPadding ->
                    App(Modifier.padding(innerPadding), navController = rememberNavController())
                }
            }
        }
    }

    companion object {

        //Reference: https://developer.2c2p.com/docs/api-payment-token
        var paymentToken = "kSAops9Zwhos8hSTSeLTUemwcv5NBQ6qxXr9Csi1NAQchXYGUUPlepIB7xId2V036tbSOXWlM4QbGE25hDeRwvfbMSIHO/jQR/O7lIAnPdXw+l2L+SG1AwuIWgZjKLix"
        var activityReference: WeakReference<Activity>? = null

        fun showAlertDialog(title: String, message: String) {

            MaterialAlertDialogBuilder(activityReference?.get()!!).apply {
                setTitle(title)
                setMessage(message)
                setPositiveButton("OK") { _, _ -> }
            }.show()
        }

        val infoApis = listOf(
            Triple(Constants.apiClientId, Pair((InfoApi)::clientId, listOf<Any>()), Icons.Outlined.Info),
            Triple(Constants.apiConfiguration, Pair((InfoApi)::configuration, listOf()), Icons.Outlined.Info),
            Triple(Constants.apiPaymentOption, Pair((InfoApi)::paymentOption, listOf()), Icons.Outlined.Info),
            Triple(Constants.apiPaymentOptionDetail, Pair((InfoApi)::paymentOptionDetail, listOf()), Icons.Outlined.Info),
            Triple(Constants.apiCustomerTokenInfo, Pair((InfoApi)::customerTokenInfo, listOf()), Icons.Outlined.Info),
            Triple(Constants.apiExchangeRate, Pair((InfoApi)::exchangeRate, listOf()), Icons.Outlined.Info),
            Triple(Constants.apiUserPreference, Pair((InfoApi)::userPreference, listOf()), Icons.Outlined.Info),
            Triple(Constants.apiTransactionStatus, Pair((InfoApi)::transactionStatus, listOf(paymentToken)), Icons.Outlined.Info),
            Triple(Constants.apiSystemInitialization, Pair((InfoApi)::systemInitialization, listOf()), Icons.Outlined.Info),
            Triple(Constants.apiPaymentNotification, Pair((InfoApi)::paymentNotification, listOf()), Icons.Outlined.Info),
            Triple(Constants.apiCancelTransaction, Pair((InfoApi)::cancelTransaction, listOf()), Icons.Outlined.Info),
            Triple(Constants.apiLoyaltyPointInfo, Pair((InfoApi)::loyaltyPointInfo, listOf()), Icons.Outlined.Info)
        )

        val paymentApis = listOf(
            Triple(Constants.paymentUI, Pair((PaymentApi)::paymentUI, listOf<Any>()), Icons.Outlined.ShoppingCart),
            Triple(Constants.paymentGlobalCreditDebitCard, Pair((PaymentApi)::globalCreditDebitCard, listOf()), Icons.Outlined.ShoppingCart),
            Triple(Constants.paymentLocalCreditDebitCard, Pair((PaymentApi)::localCreditDebitCard, listOf()), Icons.Outlined.ShoppingCart),
            Triple(Constants.paymentCustomerTokenization, Pair((PaymentApi)::customerTokenization, listOf()), Icons.Outlined.ShoppingCart),
            Triple(Constants.paymentCustomerTokenizationWithoutAuthorisation, Pair((PaymentApi)::customerTokenizationWithoutAuthorisation, listOf()), Icons.Outlined.ShoppingCart),
            Triple(Constants.paymentCustomerToken, Pair((PaymentApi)::customerToken, listOf()), Icons.Outlined.ShoppingCart),
            Triple(Constants.paymentGlobalInstallmentPaymentPlan, Pair((PaymentApi)::globalInstallmentPaymentPlan, listOf()), Icons.Outlined.ShoppingCart),
            Triple(Constants.paymentLocalInstallmentPaymentPlan, Pair((PaymentApi)::localInstallmentPaymentPlan, listOf()), Icons.Outlined.ShoppingCart),
            Triple(Constants.paymentRecurringPaymentPlan, Pair((PaymentApi)::recurringPaymentPlan, listOf()), Icons.Outlined.ShoppingCart),
            Triple(Constants.paymentThirdPartyPayment, Pair((PaymentApi)::thirdPartyPayment, listOf()), Icons.Outlined.ShoppingCart),
            Triple(Constants.paymentUserAddressForPayment, Pair((PaymentApi)::userAddressForPayment, listOf()), Icons.Outlined.ShoppingCart),
            Triple(Constants.paymentOnlineDirectDebit, Pair((PaymentApi)::onlineDirectDebit, listOf()), Icons.Outlined.ShoppingCart),
            Triple(Constants.paymentDeepLinkPayment, Pair((PaymentApi)::deepLinkPayment, listOf()), Icons.Outlined.ShoppingCart),
            Triple(Constants.paymentInternetBanking, Pair((PaymentApi)::internetBanking, listOf()), Icons.Outlined.ShoppingCart),
            Triple(Constants.paymentWebPayment, Pair((PaymentApi)::webPayment, listOf()), Icons.Outlined.ShoppingCart),
            Triple(Constants.paymentPayAtCounter, Pair((PaymentApi)::payAtCounter, listOf()), Icons.Outlined.ShoppingCart),
            Triple(Constants.paymentSelfServiceMachines, Pair((PaymentApi)::selfServiceMachines, listOf()), Icons.Outlined.ShoppingCart),
            Triple(Constants.paymentQRPayment, Pair((PaymentApi)::qrPayment, listOf()), Icons.Outlined.ShoppingCart),
            Triple(Constants.paymentBuyNowPayLater, Pair((PaymentApi)::buyNowPayLater, listOf()), Icons.Outlined.ShoppingCart),
            Triple(Constants.paymentDigitalPayment, Pair((PaymentApi)::digitalPayment, listOf()), Icons.Outlined.ShoppingCart),
            Triple(Constants.paymentLinePay, Pair((PaymentApi)::linePay, listOf()), Icons.Outlined.ShoppingCart),
            Triple(Constants.paymentGooglePay, Pair((PaymentApi)::googlePay, listOf()), Icons.Outlined.ShoppingCart),
            Triple(Constants.paymentCardLoyaltyPointPayment, Pair((PaymentApi)::cardLoyaltyPointPayment, listOf()), Icons.Outlined.ShoppingCart),
            Triple(Constants.paymentZaloPay, Pair((PaymentApi)::zaloPay, listOf()), Icons.Outlined.ShoppingCart),
            Triple(Constants.paymentCryptocurrency, Pair((PaymentApi)::cryptocurrency, listOf()), Icons.Outlined.ShoppingCart),
            Triple(Constants.paymentWebPaymentCard, Pair((PaymentApi)::webPaymentCard, listOf()), Icons.Outlined.ShoppingCart)
        )
    }
}

@Composable
fun App(
    modifier: Modifier = Modifier,
    navController: NavHostController,
    startDestination: String = "home"
) {

    PaymentApi.weakReferenceNavController = WeakReference(navController)

    NavHost(navController = navController, startDestination) {
        composable("home") { HomeScreen(modifier) }
        composable("webview/{url}/{responseCode}") { backStackEntry ->
            WebViewScreen(
                modifier,
                navController,
                Pair(
                    backStackEntry.arguments?.getString("url"),
                    backStackEntry.arguments?.getString("responseCode")
                )
            )
        }
    }
}

@Composable
fun HomeScreen(modifier: Modifier = Modifier) {

    val tabs = listOf(
        Triple("Info", Pair(InfoApi, MainActivity.infoApis), Icons.Default.Info),
        Triple("Payment", Pair(PaymentApi, MainActivity.paymentApis), Icons.Rounded.ShoppingCart)
    )

    var selectedTab by remember { mutableStateOf(Pair(0, tabs[0].second)) }
    var settingInput by remember { mutableStateOf(paymentToken) }
    var settingDialog by remember { mutableStateOf(false) }

    Scaffold(
        modifier = modifier,
        topBar = {
            Row(
                modifier.height(50.dp).padding(10.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(stringResource(R.string.app_name), fontWeight = FontWeight.Bold, fontSize = 21.sp)
                Spacer(Modifier.weight(1f))
                IconButton(onClick = { settingDialog = true }) {
                    Icon(
                        imageVector = Icons.Filled.Settings,
                        contentDescription = "Payment Token"
                    )
                }
            }
        },
        bottomBar = {
            NavigationBar {
                tabs.forEachIndexed { index, tab ->
                    NavigationBarItem(
                        icon = { Icon(imageVector = tab.third, contentDescription = tab.first) },
                        label = { Text(tab.first) },
                        selected = selectedTab.first == index,
                        onClick = { selectedTab = Pair(index, tabs[index].second) }
                    )
                }
            }
        }
    ) { innerPadding -> TabContent(selectedTab.second, innerPadding) }

    if (settingDialog) {

        AlertDialog(
            onDismissRequest = { settingDialog = false },
            title = { Text("Enter Payment Token: ") },
            text = {
                OutlinedTextField(
                    value = settingInput,
                    onValueChange = {
                        settingInput = it
                        paymentToken = it
                    },
                    label = { Text("PaymentToken: ") }
                )
            },
            confirmButton = { Button(onClick = { settingDialog = false }) { Text("OK") } }
        )
    }
}

@Composable
fun TabContent(
    apis: Pair<Any, List<Triple<Pair<String, String>, Pair<KFunction<Any>, List<Any>>, ImageVector>>>,
    innerPadding: PaddingValues
) {

    LazyColumn(modifier = Modifier.padding(innerPadding)) {
        apis.second.forEach {
            item {
                Row(
                    modifier = Modifier.fillMaxWidth().padding(10.dp),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Icon(imageVector = it.third, contentDescription = it.first.first)
                    Spacer(modifier = Modifier.padding(start = 10.dp))
                    Column(modifier = Modifier.weight(1f)) {
                        Text(it.first.first, color = Color.Black)
                        Text(it.first.second, color = Color.Gray)
                    }
                    Spacer(modifier = Modifier.padding(start = 10.dp))
                    FilledTonalButton(
                        modifier = Modifier.width(100.dp),
                        onClick = {

                            apis.first::class.members.single { api ->
                                api.name == it.second.first.name
                            }.run {

                                if (it.second.second.isEmpty()) {

                                    this.call(apis.first)
                                } else {

                                    this.call(apis.first, *it.second.second.toTypedArray())
                                }
                            }
                        }
                    ) {
                        Text("Submit")
                    }
                }
                HorizontalDivider()
            }
        }
    }
}

@SuppressLint("SetJavaScriptEnabled")
@Composable
fun WebViewScreen(modifier: Modifier = Modifier, navController: NavHostController, argument: Pair<String?, String?>) {

    val responseCode = argument.second

    if (responseCode == APIResponseCode.TransactionQRPayment) {

        val timer = Timer()

        LaunchedEffect(true) {

            timer.schedule(0L, 15000L) {

                //Reference: https://developer.2c2p.com/docs/api-sdk-transaction-status-inquiry
                //Step 1: Generate payment token.
                val paymentToken = paymentToken

                //Step 2: Construct transaction status inquiry request.
                val transactionStatusRequest = TransactionStatusRequest(paymentToken).apply {
                    additionalInfo = true
                }

                //Step 3: Retrieve transaction status inquiry response.
                PGWSDK.getInstance().transactionStatus(transactionStatusRequest, object : APIResponseCallback<TransactionStatusResponse> {

                    override fun onResponse(response: TransactionStatusResponse) {

                        if (response.responseCode != APIResponseCode.TransactionInProgress) {

                            timer.cancel()

                            navController.popBackStack()

                            showAlertDialog(Constants.apiTransactionStatus.first, StringHelper.toJson(response))
                        } else {

                            //Continue do a looping query or long polling to get transaction status until user scan the QR and make payment
                        }
                    }

                    override fun onFailure(error: Throwable) {

                        timer.cancel()

                        //Get error response and display error.
                        showAlertDialog(Constants.apiTransactionStatus.first, "Error: ${error.message ?: ""}")
                    }
                })
            }
        }

        DisposableEffect(true) {
            onDispose { timer.cancel() }
        }
    }

    Scaffold(
        modifier = modifier,
        topBar = {
            IconButton(onClick = { navController.popBackStack() }) {
                Icon(
                    imageVector = Icons.AutoMirrored.Filled.ArrowBack,
                    contentDescription = "Back"
                )
            }
        }
    ) { innerPadding ->

        AndroidView(
            modifier = modifier.padding(innerPadding),
            factory = { context ->
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
                    webViewClient = PGWWebViewClient(object : PGWWebViewTransactionStatusCallback {

                        override fun onInquiry(paymentToken: String) {

                            //Do Transaction Status Inquiry API and close this WebView.
                            navController.popBackStack()

                            InfoApi.transactionStatus(paymentToken)
                        }
                    }, object : PGWWebViewClientCallback {

                        override fun shouldOverrideUrlLoading(url: String) {

                            Log.i("PGWWebViewClient", "PGWWebViewClientCallback shouldOverrideUrlLoading : $url")
                        }

                        override fun onPageStarted(url: String) {

                            Log.i("PGWWebViewClient", "PGWWebViewClientCallback onPageStarted : $url")
                        }

                        override fun onPageFinished(url: String) {

                            Log.i("PGWWebViewClient", "PGWWebViewClientCallback onPageFinished : $url")
                        }
                    })
                }
            },
            update = { webView ->
                argument.first?.let {
                    webView.loadUrl(URLDecoder.decode(it, StandardCharsets.UTF_8.toString()))
                }
            }
        )
    }
}

@Preview(showBackground = true)
@Composable
fun GreetingPreview() {
    PGWSDKDemoApplicationTheme {
        HomeScreen()
    }
}