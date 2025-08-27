package com.ccpp.softpos.sdk.android.demo

import android.annotation.SuppressLint
import android.app.Activity
import android.os.Bundle
import android.view.ViewGroup
import android.webkit.WebResourceRequest
import android.webkit.WebSettings
import android.webkit.WebView
import android.webkit.WebViewClient
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.ArrowDropDown
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Button
import androidx.compose.material3.Checkbox
import androidx.compose.material3.DropdownMenu
import androidx.compose.material3.DropdownMenuItem
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.ExposedDropdownMenuBox
import androidx.compose.material3.ExposedDropdownMenuDefaults
import androidx.compose.material3.FilledTonalButton
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MenuAnchorType
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TextField
import androidx.compose.runtime.Composable
import androidx.compose.runtime.MutableState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.viewinterop.AndroidView
import androidx.navigation.NavHostController
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import com.ccpp.softpos.sdk.android.builder.PaymentBuilder
import com.ccpp.softpos.sdk.android.callback.PaymentResultResponseCallback
import com.ccpp.softpos.sdk.android.core.SoftPOSSDK
import com.ccpp.softpos.sdk.android.demo.helper.StringHelper
import com.ccpp.softpos.sdk.android.demo.ui.theme.SoftPOSDemoApplicationTheme
import com.ccpp.softpos.sdk.android.enums.PaymentMethodType
import com.ccpp.softpos.sdk.android.enums.SoftPOSType
import com.ccpp.softpos.sdk.android.enums.TransactionType
import com.ccpp.softpos.sdk.android.helper.WebViewClientHelper
import com.ccpp.softpos.sdk.android.payment.softpos.SoftPOSPaymentResultResponse
import java.net.URLDecoder
import java.net.URLEncoder
import java.nio.charset.StandardCharsets

/**
 * Created by DavidBilly PK on 5/6/25.
 */
class MainActivity : ComponentActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            SoftPOSDemoApplicationTheme {
                Scaffold(modifier =
                    Modifier.fillMaxSize()
                        .padding(bottom = 50.dp)
                ) { innerPadding ->
                    App(
                        Modifier.padding(innerPadding),
                        this@MainActivity,
                        navController = rememberNavController()
                    )
                }
            }
        }
    }
}

@Composable
fun App(
    modifier: Modifier = Modifier,
    activity: Activity,
    navController: NavHostController,
    startDestination: String = "home"
) {
    val transactionTypes = listOf(
        TransactionType.Transaction,
        TransactionType.TransactionAuthorization
    )
    val selectedTransactionType = remember { mutableStateOf(transactionTypes[0]) }

    NavHost(navController = navController, startDestination) {
        composable("home") { HomeLayout(activity, navController, transactionTypes, selectedTransactionType) }
        composable("webview/{url}/{profileId}") { backStackEntry ->
            WebViewScreen(
                activity,
                modifier,
                navController,
                Pair(
                    backStackEntry.arguments?.getString("url"),
                    backStackEntry.arguments?.getString("profileId")
                ),
                selectedTransactionType
            )
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun HomeLayout(
    activity: Activity,
    navController: NavHostController,
    transactionTypes: List<TransactionType>,
    transactionType: MutableState<TransactionType>
) {
    val scrollState = rememberScrollState()
    val dialogState = remember { mutableStateOf(Pair(false, "")) }
    val paymentTokenInputState = remember { mutableStateOf("kSAops9Zwhos8hSTSeLTURScbZHpjo2K75yhEuh3CrQ6B6VjqoRuQCIwOZqxq/v1+yFMtYprqgL8PA/iMO98cAH1f810z4GueCF5ln7jMCDPM5b9joqKu0ee07lkwYOxZZu8dh/MVcStVHtmwx4LkQ==") }
    val profileIdInputState = remember { mutableStateOf("prof_01JV6H6315VQAX0GY1RNPC5737") }
    val transactionIdInputState = remember { mutableStateOf("tran_01J8S46SM0MVY7B5X1RHKGNT0R") }
    val urlInputState = remember { mutableStateOf("https://pgw-ui.2c2p.com/payment/4.1/#/token/kSAops9Zwhos8hSTSeLTUTNLGXbB1hsZ3g5KCClKzNUQqwNPeW2ylqDOnm9Ftkga%2bAdFj1XnP9bUXgwJdcz5Zmt%2fwE5qxSZKnwXARPFjttWsG9YocSNZKKC4Eaf8OX3%2f") }

    if (dialogState.value.first) {
        AlertDialog(state = dialogState)
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp)
            .verticalScroll(scrollState)
    ) {
        Spacer(modifier = Modifier.height(50.dp))
        Text(
            "Pay:",
            fontSize = 30.sp,
            fontWeight = FontWeight.Bold
        )
        OutlinedTextField(
            value = paymentTokenInputState.value,
            onValueChange = { paymentTokenInputState.value = it },
            label = { Text("Payment Token: ") }
        )
        Spacer(modifier = Modifier.height(5.dp))
        OutlinedTextField(
            value = profileIdInputState.value,
            onValueChange = { profileIdInputState.value = it },
            label = { Text("Profile Id: ") }
        )
        Spacer(modifier = Modifier.height(10.dp))
        var expanded by remember { mutableStateOf(false) }
        ExposedDropdownMenuBox(
            expanded = expanded,
            onExpandedChange = { expanded = !expanded }
        ) {
            TextField(
                value = transactionType.value.name,
                onValueChange = {},
                readOnly = true,
                label = { Text("Transaction Type: ") },
                trailingIcon = {
                    ExposedDropdownMenuDefaults.TrailingIcon(expanded = expanded)
                },
                modifier = Modifier.menuAnchor(MenuAnchorType.PrimaryNotEditable, true)//.menuAnchor()
            )
            ExposedDropdownMenu(
                expanded = expanded,
                onDismissRequest = { expanded = false }
            ) {
                transactionTypes.forEach { item ->
                    DropdownMenuItem(
                        text = { Text(item.name) },
                        onClick = {
                            transactionType.value = item
                            expanded = false
                        }
                    )
                }
            }
        }
        Spacer(modifier = Modifier.height(10.dp))
        var selectedMethods by remember { mutableStateOf(enumValues<PaymentMethodType>().toList()) }
        PaymentMethods(
            onItemSelected = {
                selectedMethods = it
            }
        )
        Spacer(modifier = Modifier.height(10.dp))
        FilledTonalButton(onClick = {
            pay(
                activity,
                paymentTokenInputState.value,
                profileIdInputState.value,
                transactionType.value,
                selectedMethods,
                object : PaymentResultResponseCallback<SoftPOSPaymentResultResponse> {

                    override fun onResponse(response: SoftPOSPaymentResultResponse) {
                        dialogState.value = Pair(true, StringHelper.toJson(response))
                    }

                    override fun onFailure(error: Throwable) {
                        dialogState.value = Pair(true, error.message ?: "")
                    }
                })
        }) {
            Text("Scan & Pay")
        }
        Spacer(modifier = Modifier.height(50.dp))
        Text(
            "Void:",
            fontSize = 30.sp,
            fontWeight = FontWeight.Bold
        )
        OutlinedTextField(
            value = transactionIdInputState.value,
            onValueChange = { transactionIdInputState.value = it },
            label = { Text("Transaction Id: ") }
        )
        Spacer(modifier = Modifier.height(10.dp))
        FilledTonalButton(onClick = {
            val paymentRequest = PaymentBuilder(activity, paymentTokenInputState.value)
                .transactionId(transactionIdInputState.value)
                .build()

            SoftPOSSDK.getInstance().voidTransaction(paymentRequest, object : PaymentResultResponseCallback<SoftPOSPaymentResultResponse> {

                override fun onResponse(response: SoftPOSPaymentResultResponse) {
                    dialogState.value = Pair(true, StringHelper.toJson(response))
                }

                override fun onFailure(error: Throwable) {
                    dialogState.value = Pair(true, error.message ?: "")
                }
            })
        }) {
            Text("Void Payment")
        }
        Spacer(modifier = Modifier.height(50.dp))
        Text(
            "Query:",
            fontSize = 30.sp,
            fontWeight = FontWeight.Bold
        )
        OutlinedTextField(
            value = transactionIdInputState.value,
            onValueChange = { transactionIdInputState.value = it },
            label = { Text("Transaction Id: ") }
        )
        Spacer(modifier = Modifier.height(10.dp))
        FilledTonalButton(onClick = {
            val paymentRequest = PaymentBuilder(activity, paymentTokenInputState.value)
                .transactionId(transactionIdInputState.value)
                .build()

            SoftPOSSDK.getInstance().query(paymentRequest, object : PaymentResultResponseCallback<SoftPOSPaymentResultResponse> {

                override fun onResponse(response: SoftPOSPaymentResultResponse) {
                    dialogState.value = Pair(true, StringHelper.toJson(response))
                }

                override fun onFailure(error: Throwable) {
                    dialogState.value = Pair(true, error.message ?: "")
                }
            })
        }) {
            Text("Query transaction")
        }
        Spacer(modifier = Modifier.height(50.dp))
        Text(
            "V4 UI:",
            fontSize = 30.sp,
            fontWeight = FontWeight.Bold
        )
        OutlinedTextField(
            value = urlInputState.value,
            onValueChange = { urlInputState.value = it },
            label = { Text("Url: ") }
        )
        Spacer(modifier = Modifier.height(10.dp))
        FilledTonalButton(onClick = {
            val encodedUrl = URLEncoder.encode(urlInputState.value, StandardCharsets.UTF_8.toString())
            navController.navigate("webview/$encodedUrl/${profileIdInputState.value}")
        }) {
            Text("Redirect")
        }
    }
}

@SuppressLint("SetJavaScriptEnabled")
@Composable
fun WebViewScreen(
    activity: Activity,
    modifier: Modifier = Modifier,
    navController: NavHostController,
    argument: Pair<String?, String?>,
    transactionType: MutableState<TransactionType>
) {
    val webPaymentUrl = argument.first
    val profileId = argument.second
    val dialogState = remember { mutableStateOf(Pair(false, "")) }

    if (dialogState.value.first) {
        AlertDialog(state = dialogState)
    }

    Scaffold(
        modifier = modifier
            .fillMaxWidth()
            .padding(bottom = 50.dp),
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
            modifier =
                modifier
                    .fillMaxWidth()
                    .padding(innerPadding),
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
                    webViewClient = object : WebViewClient() {

                        override fun shouldOverrideUrlLoading(view: WebView, request: WebResourceRequest): Boolean {
                            val overrideUrl = request.url.toString()
                            if (WebViewClientHelper.handle(overrideUrl)) {

                                val paymentToken = WebViewClientHelper.paymentToken(overrideUrl) ?: ""
                                val paymentResultUrl = WebViewClientHelper.paymentResultUrl(webPaymentUrl) ?: ""

                                pay(
                                    activity,
                                    paymentToken,
                                    profileId ?: "",
                                    transactionType.value,
                                    enumValues<PaymentMethodType>().toList(),
                                    object : PaymentResultResponseCallback<SoftPOSPaymentResultResponse> {

                                        override fun onResponse(response: SoftPOSPaymentResultResponse) {
                                            dialogState.value =
                                                Pair(true, StringHelper.toJson(response))
                                            view.loadUrl(paymentResultUrl)
                                        }

                                        override fun onFailure(error: Throwable) {
                                            dialogState.value = Pair(true, error.message ?: "")
                                            view.loadUrl(paymentResultUrl)
                                        }
                                    })
                                return true
                            } else {
                                return super.shouldOverrideUrlLoading(view, request)
                            }
                        }
                    }
                }
            },
            update = { webView ->
                webPaymentUrl?.let {
                    webView.loadUrl(URLDecoder.decode(it, StandardCharsets.UTF_8.toString()))
                }
            }
        )
    }
}

@Composable
fun AlertDialog(state: MutableState<Pair<Boolean, String>>) {
    if (state.value.first) {
        AlertDialog(
            onDismissRequest = {
                state.value = Pair(false, "")
            },
            title = { Text(text = "Result: ") },
            text = { Text(text = state.value.second, modifier = Modifier.verticalScroll(rememberScrollState())) },
            confirmButton = {
                Button(
                    onClick = {
                        state.value = Pair(false, "")
                    }
                ) {
                    Text(
                        text = "OK"
                    )
                }
            }
        )
    }
}

@SuppressLint("MutableCollectionMutableState")
@Composable
fun PaymentMethods(
    onItemSelected: (List<PaymentMethodType>) -> Unit
) {
    var expanded by remember { mutableStateOf(false) }
    var selectedItems by remember { mutableStateOf(enumValues<PaymentMethodType>().toMutableList()) }

    Column(modifier = Modifier.fillMaxWidth()) {
        OutlinedTextField(
            value = selectedItems.joinToString { it.name },
            onValueChange = { },
            modifier = Modifier.fillMaxWidth(),
            label = { Text("Payment Methods:") },
            trailingIcon = {
                Icon(
                    Icons.Filled.ArrowDropDown,
                    "Arrow",
                    Modifier.clickable { expanded = !expanded }
                )
            },
            readOnly = true
        )
        DropdownMenu(
            expanded = expanded,
            onDismissRequest = { expanded = false }
        ) {
            PaymentMethodType.entries.forEach { item ->
                val selected = remember { mutableStateOf(item in selectedItems) }
                DropdownMenuItem(
                    text = {
                        Row(
                            verticalAlignment = Alignment.CenterVertically,
                            horizontalArrangement = Arrangement.SpaceBetween,
                            modifier = Modifier.fillMaxWidth()
                        ) {
                            Text(text = item.name, fontSize = 16.sp)
                            Checkbox(
                                checked = selected.value,
                                onCheckedChange = { checked ->
                                    if (checked) {
                                        selectedItems.add(item)
                                    } else {
                                        selectedItems.remove(item)
                                    }
                                    selected.value = checked
                                    onItemSelected(selectedItems.distinct())
                                }
                            )
                        }
                    },
                    onClick = {
                        if (item in selectedItems) {
                            selectedItems.remove(item)
                        } else {
                            selectedItems.add(item)
                        }
                        selected.value = !selected.value
                        onItemSelected(selectedItems.distinct())
                    }
                )
            }
        }
    }
}

fun pay(activity: Activity, paymentToken: String, profileId: String, transactionType: TransactionType, paymentMethods: List<PaymentMethodType>, response: PaymentResultResponseCallback<SoftPOSPaymentResultResponse>) {

    val paymentRequest = PaymentBuilder(activity, paymentToken)
        .transactionType(transactionType)
        .profileId(profileId)
        .posType(SoftPOSType.Mobile)
        .paymentMethods(paymentMethods)
        .build()

    SoftPOSSDK.getInstance().pay(paymentRequest, response)
}

@Preview(showBackground = true)
@Composable
fun GreetingPreview() {
    SoftPOSDemoApplicationTheme { }
}