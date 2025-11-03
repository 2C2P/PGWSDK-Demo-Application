package com.ccpp.softpos.sdk.android.demo.app2app

import android.os.Bundle
import android.widget.Toast
import androidx.activity.ComponentActivity
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.activity.result.launch
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.text.selection.SelectionContainer
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Button
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TextField
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.ccpp.softpos.sdk.android.demo.app2app.ui.theme.SoftPOSDemoApplicationForAppToAppTheme
import com.theminesec.app.poslib.MsaPosApi
import com.theminesec.app.poslib.model.PosRequest
import com.theminesec.app.poslib.model.PosResponse
import com.theminesec.app.poslib.model.PreferredInstrument
import java.math.BigDecimal

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        val msaPosApi = MsaPosApi(packageName = "com.ccpp.softpos.android")
        setContent {
            SoftPOSDemoApplicationForAppToAppTheme {
                WarmUpScreen(msaPosApi = msaPosApi)
            }
        }
    }
}

@Composable
fun WarmUpScreen(
    msaPosApi: MsaPosApi
) {
    val context = LocalContext.current
    val appInstalled = try {
        msaPosApi.isSoftPosInstalled(context)
    } catch (e: Exception) {
        e.printStackTrace()
        false
    }
    var initialized by remember { mutableStateOf(value = false) }
    Scaffold(
        modifier = Modifier.fillMaxSize()
    ) { innerPadding ->
        Column(
            modifier = Modifier
                .padding(paddingValues = innerPadding)
                .fillMaxSize(),
            verticalArrangement = Arrangement.Center,
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            if (appInstalled) {
                val warmUpLauncher = rememberLauncherForActivityResult(
                    contract = msaPosApi.warmUpContract()
                ) { result ->
                    when (result) {
                        is PosResponse.Success -> {
                            initialized = true
                        }
                        is PosResponse.Failed -> {
                            Toast.makeText(
                                context,
                                "Failed: "
                                    .plus(other = result.rspCode)
                                    .plus(other = " : ")
                                    .plus(other = result.rspMsg),
                                Toast.LENGTH_SHORT
                            ).show()
                        }
                    }
                }
                LaunchedEffect(key1 = Unit) {
                    warmUpLauncher.launch()
                }
                if (initialized) MainScreen(msaPosApi = msaPosApi)
            } else {
                Text(text = "2C2P SoftPOS app are not install on current device.")
            }
        }
    }
}

@Composable
fun MainScreen(
    msaPosApi: MsaPosApi
) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .verticalScroll(state = rememberScrollState())
            .padding(all = 20.dp)
    ) {
        Spacer(modifier = Modifier.height(height = 20.dp))
        ActivationScreen(msaPosApi = msaPosApi)
        Spacer(modifier = Modifier.height(height = 20.dp))
        PaymentScreen(msaPosApi = msaPosApi)
        Spacer(modifier = Modifier.height(height = 20.dp))
        VoidScreen(msaPosApi = msaPosApi)
        Spacer(modifier = Modifier.height(height = 20.dp))
        InquiryScreen(msaPosApi = msaPosApi)
    }
}

@Composable
fun ActivationScreen(
    msaPosApi: MsaPosApi
) {
    var activationCode by remember { mutableStateOf(value = "964726358811") }
    var result by remember { mutableStateOf(value = "") }
    val activationLauncher = rememberLauncherForActivityResult(
        contract = msaPosApi.activationContract()
    ) {
        result = when (it) {
            is PosResponse.Success -> {
                "Success: ${it.rspCode} - ${it.rspMsg}"
            }

            is PosResponse.Failed -> {
                "Failed: ${it.rspCode} - ${it.rspMsg}"
            }
        }
    }
    Text(
        text = "Activation: ",
        fontSize = 25.sp,
        fontWeight = FontWeight.Bold
    )
    TextField(
        value = activationCode,
        modifier = Modifier.fillMaxWidth(),
        onValueChange = {
            activationCode = it
        },
        label = {
            Text(text = "Activation Code: ")
        }
    )
    Button(
        onClick = {
            activationLauncher.launch(
                input =
                    PosRequest.Activation(activationCode = activationCode)
            )
        },
        modifier = Modifier.padding(top = 5.dp)
    ) {
        Text(text = "Activate")
    }
    SelectionContainer {
        Column {
            Text(text = "Activation result: ")
            Text(text = result)
        }
    }
}

@Composable
fun PaymentScreen(
    msaPosApi: MsaPosApi
) {
    var amount by remember { mutableStateOf(value = "0.01") }
    var posMessageId by remember { mutableStateOf(value = "POS_PAYMENT_${System.currentTimeMillis()}") }
    var originalTransactionId by remember { mutableStateOf(value = "M1985190949813792770") }
    var result by remember { mutableStateOf(value = "") }
    val transactionLauncher = rememberLauncherForActivityResult(
        contract = msaPosApi.transactionContract()
    ) {
        result = when (it) {
            is PosResponse.Success -> {
                mapOf(
                    "data" to it.data,
                    "rspCode" to it.rspCode,
                    "rspMsg" to it.rspMsg
                ).toString()
            }
            is PosResponse.Failed -> {
                mapOf(
                    "tranId" to it.tranId,
                    "rspCode" to it.rspCode,
                    "rspMsg" to it.rspMsg
                ).toString()
            }
        }
    }
    Text(
        text = "Payment: ",
        fontSize = 25.sp,
        fontWeight = FontWeight.Bold
    )
    TextField(
        value = amount,
        modifier = Modifier.fillMaxWidth(),
        onValueChange = {
            amount = it
        },
        label = {
            Text(text = "Amount: ")
        },
        keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number)
    )
    TextField(
        value = posMessageId,
        modifier = Modifier
            .fillMaxWidth()
            .padding(top = 5.dp),
        onValueChange = {
            posMessageId = it
        },
        label = {
            Text(text = "POS Message ID: ")
        }
    )
    Button(
        onClick = {
            transactionLauncher.launch(
                input =
                    PosRequest.Transaction.Sale(
                        amount = BigDecimal(amount),
                        posMessageId = posMessageId,
                        autoDismissResult = true
                    )
            )
        },
        modifier = Modifier.padding(top = 5.dp)
    ) {
        Text(text = "Card: Sale Transaction")
    }
    Button(
        onClick = {
            transactionLauncher.launch(
                input =
                    PosRequest.Transaction.Auth(
                        amount = BigDecimal(amount),
                        posMessageId = posMessageId,
                        autoDismissResult = true
                    )
            )
        },
        modifier = Modifier.padding(top = 5.dp)
    ) {
        Text(text = "Card: Auth Transaction")
    }
    Button(
        onClick = {
            transactionLauncher.launch(
                input =
                    PosRequest.Transaction.AuthCompletion(
                        orgTranId = originalTransactionId,
                        amount = BigDecimal(amount),
                        posMessageId = posMessageId
                    )
            )
        },
        modifier = Modifier.padding(top = 5.dp)
    ) {
        Text(text = "Card: Auth Completion (Capture)")
    }
    Button(
        onClick = {
            transactionLauncher.launch(
                input =
                    PosRequest.Transaction.Sale(
                        amount = BigDecimal(amount),
                        posMessageId = posMessageId,
                        autoDismissResult = true,
                        preferredInstrument = PreferredInstrument.QR_GUEST_SCAN,
                        qrPaymentMethods = null
                    )
            )
        },
        modifier = Modifier.padding(top = 5.dp)
    ) {
        Text(text = "QR: Scan By Customer")
    }
    SelectionContainer {
        Column {
            Text(text = "Payment result:")
            Text(text = result)
        }
    }
}

@Composable
fun VoidScreen(
    msaPosApi: MsaPosApi
) {
    var originalTransactionId by remember { mutableStateOf(value = "") }
    var posMessageId by remember { mutableStateOf(value = "POS_VOID_${System.currentTimeMillis()}") }
    var adminPassword by remember { mutableStateOf(value = "") }
    var result by remember { mutableStateOf(value = "") }
    val transactionLauncher = rememberLauncherForActivityResult(
        contract = msaPosApi.transactionContract()
    ) {
        result = when (it) {
            is PosResponse.Success -> {
                mapOf(
                    "data" to it.data,
                    "rspCode" to it.rspCode,
                    "rspMsg" to it.rspMsg
                ).toString()
            }
            is PosResponse.Failed -> {
                mapOf(
                    "tranId" to it.tranId,
                    "rspCode" to it.rspCode,
                    "rspMsg" to it.rspMsg
                ).toString()
            }
        }
    }
    Text(
        text = "Void: ",
        fontSize = 25.sp,
        fontWeight = FontWeight.Bold
    )
    TextField(
        value = originalTransactionId,
        modifier = Modifier
            .fillMaxWidth()
            .padding(top = 5.dp),
        onValueChange = {
            originalTransactionId = it
        },
        label = {
            Text(text = "Transaction ID: ")
        }
    )
    TextField(
        value = posMessageId,
        modifier = Modifier
            .fillMaxWidth()
            .padding(top = 5.dp),
        onValueChange = {
            posMessageId = it
        },
        label = {
            Text(text = "POS Message ID: ")
        }
    )
    TextField(
        value = adminPassword,
        modifier = Modifier
            .fillMaxWidth()
            .padding(top = 5.dp),
        onValueChange = {
            adminPassword = it
        },
        label = {
            Text(text = "Admin Password: ")
        },
        keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Password)
    )
    Button(
        onClick = {
            transactionLauncher.launch(
                input =
                    PosRequest.Transaction.Void(
                        orgTranId = originalTransactionId,
                        posMessageId = posMessageId,
                        adminPwd = adminPassword
                    )
            )
        },
        modifier = Modifier.padding(top = 5.dp)
    ) {
        Text(text = "Void Transaction")
    }
    SelectionContainer {
        Column {
            Text(text = "Void result: ")
            Text(text = result)
        }
    }
}

@Composable
fun InquiryScreen(
    msaPosApi: MsaPosApi
) {
    var originalTransactionId by remember { mutableStateOf(value = "M1985190949813792770") }
    var result by remember { mutableStateOf(value = "") }
    val enquiryLauncher = rememberLauncherForActivityResult(
        contract = msaPosApi.enquiryTranStatusContract()
    ) {
        result = when (it) {
            is PosResponse.Success -> {
                mapOf(
                    "data" to it.data,
                    "rspCode" to it.rspCode,
                    "rspMsg" to it.rspMsg
                ).toString()
            }
            is PosResponse.Failed -> {
                mapOf(
                    "tranId" to it.tranId,
                    "rspCode" to it.rspCode,
                    "rspMsg" to it.rspMsg
                ).toString()
            }
        }
    }
    Text(
        text = "Inquiry: ",
        fontSize = 25.sp,
        fontWeight = FontWeight.Bold
    )
    TextField(
        value = originalTransactionId,
        modifier = Modifier
            .fillMaxWidth()
            .padding(top = 5.dp),
        onValueChange = {
            originalTransactionId = it
        },
        label = {
            Text(text = "Transaction ID: ")
        }
    )
    Button(
        onClick = {
            enquiryLauncher.launch(
                input =
                    PosRequest.EnquiryTranStatus(
                        orgTranId = originalTransactionId
                    )
            )
        },
        modifier = Modifier.padding(top = 5.dp)
    ) {
        Text(text = "Inquiry Transaction")
    }
    SelectionContainer {
        Column {
            Text(text = "Inquiry result: ")
            Text(text = result)
        }
    }
}