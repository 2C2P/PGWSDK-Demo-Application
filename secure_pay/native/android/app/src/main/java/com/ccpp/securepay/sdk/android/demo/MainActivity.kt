package com.ccpp.securepay.sdk.android.demo

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.text.selection.SelectionContainer
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.CreditCard
import androidx.compose.material3.Button
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.ccpp.pgw.sdk.android.securepay.APIEnvironment
import com.ccpp.pgw.sdk.android.securepay.Payload
import com.ccpp.pgw.sdk.android.securepay.SecurePaySDK
import com.ccpp.securepay.sdk.android.demo.ui.theme.SecurePaySDKDemoApplicationTheme
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

/**
 * Created by DavidBilly PK on 11/2/25.
 */
class MainActivity : ComponentActivity() {

    //Step 1 : Initialize SecurePay SDK
    private val sdk = SecurePaySDK(APIEnvironment.Sandbox)

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            SecurePaySDKDemoApplicationTheme {
                Scaffold(modifier = Modifier.fillMaxSize()) { innerPadding ->
                    Modifier.padding(innerPadding)
                    CreditCardForm(sdk)
                }
            }
        }
    }
}

@Composable
fun CreditCardForm(sdk: SecurePaySDK) {

    val coroutineScope = rememberCoroutineScope()
    val scrollState = rememberScrollState()
    var cardNo by remember { mutableStateOf("4111111111111111") }
    var expiryMonth by remember { mutableStateOf("12") }
    var expiryYear by remember { mutableStateOf("2027") }
    var issuedMonth by remember { mutableStateOf("1") }
    var issuedYear by remember { mutableStateOf("2023") }
    var securityCode by remember { mutableStateOf("123") }
    var pin by remember { mutableStateOf("123456") }
    var merchantId by remember { mutableStateOf("JT01") }
    var paymentToken by remember { mutableStateOf("kSAops9Zwhos8hSTSeLTUZAnjU4qHcwtRio0kjOi6zn6oAbSRy5GcWdqI0PjHS0ANaDffORbaH3sk+PcrpJfwOsNnljxpScgWhqJLSUhSZkUlT2vPadQo6UuuD+7ej1A") }
    var securePayToken by remember { mutableStateOf("") }
    var maskedCardNo by remember { mutableStateOf("") }

    Column(
        modifier = Modifier
            .fillMaxWidth()
            .padding(16.dp)
            .verticalScroll(scrollState),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Icon(
            imageVector = Icons.Filled.CreditCard,
            contentDescription = "Credit Card Icon",
            modifier = Modifier.size(48.dp),
            tint = MaterialTheme.colorScheme.primary
        )
        Spacer(modifier = Modifier.height(16.dp))
        OutlinedTextField(
            value = cardNo,
            onValueChange = { newValue ->
                cardNo = newValue.take(19)
            },
            label = { Text("Card No") },
            modifier = Modifier.fillMaxWidth(),
            keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
            singleLine = true
        )
        Spacer(modifier = Modifier.height(6.dp))
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween
        ) {
            OutlinedTextField(
                value = expiryMonth,
                onValueChange = { newValue ->
                    expiryMonth = newValue.take(2)
                },
                label = { Text("Expiry Month") },
                modifier = Modifier.weight(1f).padding(end = 8.dp),
                keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                singleLine = true
            )
            OutlinedTextField(
                value = expiryYear,
                onValueChange = { newValue ->
                    expiryYear = newValue.take(4)
                },
                label = { Text("Expiry Year") },
                modifier = Modifier.weight(1f).padding(start = 8.dp),
                keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                singleLine = true
            )
        }
        Spacer(modifier = Modifier.height(6.dp))
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween
        ) {
            OutlinedTextField(
                value = issuedMonth,
                onValueChange = { newValue ->
                    issuedMonth = newValue.take(2)
                },
                label = { Text("Issued Month") },
                modifier = Modifier.weight(1f).padding(end = 8.dp),
                keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                singleLine = true
            )
            OutlinedTextField(
                value = issuedYear,
                onValueChange = { newValue ->
                    issuedYear = newValue.take(4)
                },
                label = { Text("Issued Year") },
                modifier = Modifier.weight(1f).padding(start = 8.dp),
                keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                singleLine = true
            )
        }
        Spacer(modifier = Modifier.height(6.dp))
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween
        ) {
            OutlinedTextField(
                value = securityCode,
                onValueChange = { newValue ->
                    securityCode = newValue.take(4)
                },
                label = { Text("Security Code") },
                modifier = Modifier.weight(1f).padding(end = 8.dp),
                keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                singleLine = true
            )
            OutlinedTextField(
                value = pin,
                onValueChange = { newValue ->
                    pin = newValue.take(6)
                },
                label = { Text("Pin") },
                modifier = Modifier.weight(1f).padding(start = 8.dp),
                keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.NumberPassword),
                singleLine = true
            )
        }
        Spacer(modifier = Modifier.height(6.dp))
        OutlinedTextField(
            value = merchantId,
            onValueChange = { merchantId = it },
            label = { Text("Merchant Id") },
            modifier = Modifier.fillMaxWidth(),
            keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Text),
            singleLine = true
        )
        Spacer(modifier = Modifier.height(6.dp))
        OutlinedTextField(
            value = paymentToken,
            onValueChange = { paymentToken = it },
            label = { Text("Payment Token") },
            modifier = Modifier.fillMaxWidth(),
            keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Text),
            maxLines = 5
        )
        Spacer(modifier = Modifier.height(16.dp))

        //Step 2: Construct payload.
        val payload = Payload().apply {
            this.cardNo = cardNo
            this.expiryMonth = expiryMonth.toIntOrNull() ?: 0
            this.expiryYear = expiryYear.toIntOrNull() ?: 0
            this.issuedMonth = issuedMonth.toIntOrNull() ?: 0
            this.issuedYear = issuedYear.toIntOrNull() ?: 0
            this.securityCode = securityCode
            this.pin = pin

            //Note: merchantId or paymentToken one of them is required.
            this.merchantId = merchantId
            this.paymentToken = paymentToken
        }

        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween
        ) {
            Button(onClick = {

                println("Card No: ${payload.cardNo}")
                println("Expiry Date: ${payload.expiryMonth} / ${payload.expiryYear}")
                println("Issued Date: ${payload.issuedMonth} / ${payload.issuedYear}")
                println("Security Code: ${payload.securityCode} / Pin: ${payload.pin}")
                println("Merchant ID: ${payload.merchantId} / Payment Token: ${payload.paymentToken}")

                //Step 3: Generate token.
                securePayToken = sdk.token(payload)

                coroutineScope.launch {
                    delay(800)
                    scrollState.animateScrollTo(scrollState.maxValue)
                }
            }, modifier = Modifier.weight(1f).padding(start = 8.dp)) {
                Text("Generate Token")
            }
            Button(onClick = {
                maskedCardNo = payload.maskedCardNo()
            }, modifier = Modifier.weight(1f).padding(start = 8.dp)) {
                Text("Masked Card No")
            }
        }
        Spacer(modifier = Modifier.height(16.dp))
        SelectionContainer {
            Text("Masked Card No: $maskedCardNo")
        }
        Spacer(modifier = Modifier.height(16.dp))
        SelectionContainer {
            Text("Secure Pay Token: $securePayToken")
        }
        Spacer(modifier = Modifier.height(16.dp))
    }
}

@Preview(showBackground = true)
@Composable
fun Preview() {
    SecurePaySDKDemoApplicationTheme {
        CreditCardForm(sdk = SecurePaySDK(APIEnvironment.Sandbox))
    }
}