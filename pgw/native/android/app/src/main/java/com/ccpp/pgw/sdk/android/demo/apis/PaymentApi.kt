package com.ccpp.pgw.sdk.android.demo.apis

import androidx.navigation.NavController
import com.ccpp.pgw.sdk.android.builder.BuyNowPayLaterPaymentBuilder
import com.ccpp.pgw.sdk.android.builder.CardPaymentBuilder
import com.ccpp.pgw.sdk.android.builder.CustomerTokenPaymentBuilder
import com.ccpp.pgw.sdk.android.builder.DeepLinkPaymentBuilder
import com.ccpp.pgw.sdk.android.builder.DigitalCurrencyBuilder
import com.ccpp.pgw.sdk.android.builder.DigitalPaymentBuilder
import com.ccpp.pgw.sdk.android.builder.InternetBankingBuilder
import com.ccpp.pgw.sdk.android.builder.LoyaltyPointPaymentBuilder
import com.ccpp.pgw.sdk.android.builder.OnlineDirectDebitBuilder
import com.ccpp.pgw.sdk.android.builder.PayAtCounterBuilder
import com.ccpp.pgw.sdk.android.builder.PaymentUIBuilder
import com.ccpp.pgw.sdk.android.builder.QRPaymentBuilder
import com.ccpp.pgw.sdk.android.builder.SelfServiceMachineBuilder
import com.ccpp.pgw.sdk.android.builder.TransactionResultRequestBuilder
import com.ccpp.pgw.sdk.android.builder.UserAddressBuilder
import com.ccpp.pgw.sdk.android.builder.WebPaymentBuilder
import com.ccpp.pgw.sdk.android.callback.APIResponseCallback
import com.ccpp.pgw.sdk.android.core.PGWSDK
import com.ccpp.pgw.sdk.android.demo.Constants
import com.ccpp.pgw.sdk.android.demo.MainActivity.Companion.activityReference
import com.ccpp.pgw.sdk.android.demo.MainActivity.Companion.paymentToken
import com.ccpp.pgw.sdk.android.demo.MainActivity.Companion.showAlertDialog
import com.ccpp.pgw.sdk.android.demo.helper.StringHelper
import com.ccpp.pgw.sdk.android.enums.APIResponseCode
import com.ccpp.pgw.sdk.android.enums.InstallmentInterestTypeCode
import com.ccpp.pgw.sdk.android.enums.PaymentChannelCode
import com.ccpp.pgw.sdk.android.enums.QRTypeCode
import com.ccpp.pgw.sdk.android.model.LoyaltyPoint
import com.ccpp.pgw.sdk.android.model.LoyaltyPointReward
import com.ccpp.pgw.sdk.android.model.PaymentCode
import com.ccpp.pgw.sdk.android.model.UserAddress
import com.ccpp.pgw.sdk.android.model.UserBillingAddress
import com.ccpp.pgw.sdk.android.model.api.PaymentOptionDetailRequest
import com.ccpp.pgw.sdk.android.model.api.PaymentOptionDetailResponse
import com.ccpp.pgw.sdk.android.model.api.TransactionResultRequest
import com.ccpp.pgw.sdk.android.model.api.TransactionResultResponse
import com.ccpp.pgw.sdk.helper.android.builder.PaymentProviderBuilder
import com.ccpp.pgw.sdk.helper.android.callback.PaymentResultResponseCallback
import com.ccpp.pgw.sdk.helper.android.core.PGWSDKHelper
import com.ccpp.pgw.sdk.helper.android.payment.deeplink.DeepLinkPaymentResponseCode
import com.ccpp.pgw.sdk.helper.android.payment.deeplink.DeepLinkPaymentResultResponse
import com.ccpp.pgw.sdk.helper.android.payment.googlepay.GooglePayPaymentResponseCode
import com.ccpp.pgw.sdk.helper.android.payment.googlepay.GooglePayPaymentResultResponse
import com.ccpp.pgw.sdk.helper.android.payment.zalopay.ZaloPayPaymentResponseCode
import com.ccpp.pgw.sdk.helper.android.payment.zalopay.ZaloPayPaymentResultResponse
import com.google.android.gms.wallet.WalletConstants
import kotlinx.coroutines.DelicateCoroutinesApi
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.async
import kotlinx.coroutines.launch
import java.lang.ref.WeakReference
import java.net.URLEncoder
import java.nio.charset.StandardCharsets
import kotlin.coroutines.suspendCoroutine

/**
 * Created by DavidBilly PK on 23/12/24.
 */
object PaymentApi {

    var weakReferenceNavController: WeakReference<NavController>? = null

    //Reference: https://developer.2c2p.com/docs/sdk-api-do-payment
    private fun proceedTransaction(request: TransactionResultRequest) {

        PGWSDK.getInstance().proceedTransaction(request, object : APIResponseCallback<TransactionResultResponse> {

            override fun onResponse(response: TransactionResultResponse) {

                if (response.responseCode == APIResponseCode.TransactionAuthenticateRedirect || response.responseCode == APIResponseCode.TransactionAuthenticateFullRedirect) {

                    val redirectUrl = response.data //Open WebView
                    handleRedirectUrl(redirectUrl)
                } else if (response.responseCode == APIResponseCode.TransactionExternalBrowser) {

                    handleDeepLinkPayment(response)
                } else if (response.responseCode == APIResponseCode.TransactionPaymentSlip) {

                    val paymentSlip = response.data //Open payment slip on WebView
                    handleRedirectUrl(paymentSlip)
                } else if (response.responseCode == APIResponseCode.TransactionExternalApplication) {

                    if (response.channelCode == PaymentChannelCode.Channel.ZaloPay) {

                        handleZaloPay(response)
                    } else {

                        handleDeepLinkPayment(response)
                    }
                } else if (response.responseCode == APIResponseCode.TransactionQRPayment) {

                    val qrUrl = response.data //Display QR image by using url.
                    val responseCode = response.responseCode
                    handleRedirectUrl(qrUrl, responseCode)
                } else if (response.responseCode == APIResponseCode.TransactionCompleted) {

                    //Inquiry payment result by using invoice no.
                    InfoApi.transactionStatus(paymentToken)
                } else {

                    //Get error response and display error.
                    showAlertDialog(Constants.apiDoPayment.first, StringHelper.toJson(response))
                }
            }

            override fun onFailure(error: Throwable) {

                //Get error response and display error.
                showAlertDialog(Constants.apiDoPayment.first, "Error: ${error.message ?: ""}")
            }
        })
    }

    //Reference: https://developer.2c2p.com/docs/sdk-handle-pgw-payment-authentication
    fun handleRedirectUrl(url: String, responseCode: String = "") {

        val encodedUrl = URLEncoder.encode(url, StandardCharsets.UTF_8.toString())
        weakReferenceNavController?.get()?.navigate("webview/$encodedUrl/$responseCode")
    }

    //Reference: https://developer.2c2p.com/docs/sdk-references-handle-deeplink-payment-flow-by-pgw-sdk-helper
    fun handleDeepLinkPayment(response: TransactionResultResponse) {

        //Step 5: Construct deep link payment request.
        val paymentProviderRequest = PaymentProviderBuilder(activityReference?.get()).apply {
            transactionResultResponse(response)
        }.build()

        PGWSDKHelper.getInstance().proceedDeepLinkPayment(paymentProviderRequest, object : PaymentResultResponseCallback<DeepLinkPaymentResultResponse> {

            override fun onResponse(response: DeepLinkPaymentResultResponse) {

                if (response.responseCode == DeepLinkPaymentResponseCode.PaymentTransactionStatusInquiry) {

                    //Inquiry payment result by using payment token.
                    InfoApi.transactionStatus(paymentToken)
                }
            }

            override fun onFailure(error: Throwable) {

                //Get error response and display error.
                showAlertDialog(Constants.apiDoPayment.first, "Error: ${error.message ?: ""}")
            }
        })
    }

    //Reference: https://developer.2c2p.com/docs/sdk-method-zalopay
    fun handleZaloPay(response: TransactionResultResponse) {

        //Step 5: Construct ZaloPay payment request.
        val paymentProviderRequest = PaymentProviderBuilder(activityReference?.get()).apply {
            transactionResultResponse(response)
        }.build()

        PGWSDKHelper.getInstance().proceedZaloPayPayment(paymentProviderRequest, object : PaymentResultResponseCallback<ZaloPayPaymentResultResponse> {

            override fun onResponse(response: ZaloPayPaymentResultResponse) {

                if (response.responseCode == ZaloPayPaymentResponseCode.PaymentSuccess) {

                    //Inquiry payment result by using payment token.
                } else {

                    //Get error response and display error.
                }

                showAlertDialog(Constants.apiDoPayment.first, StringHelper.toJson(response))
            }

            override fun onFailure(error: Throwable) {

                //Get error response and display error.
                showAlertDialog(Constants.apiDoPayment.first, "Error: ${error.message ?: ""}")
            }
        })
    }

    //Reference: https://developer.2c2p.com/docs/sdk-api-payment-ui
    fun paymentUI() {

        //Step 2: Construct payment ui request.
        val paymentUIRequest = PaymentUIBuilder(activityReference?.get()).build()

        //Step 3: Construct transaction request.
        val transactionResultRequest = TransactionResultRequestBuilder(paymentToken).apply {
            with(paymentUIRequest)
        }.build()

        //Step 4: Execute payment ui request.
        proceedTransaction(transactionResultRequest)
    }

    //Reference: https://developer.2c2p.com/docs/sdk-method-credit-debit-card
    fun globalCreditDebitCard() {

        //Step 1: Generate payment token.
        val paymentToken = paymentToken

        //Step 2: Construct credit card request.
        val paymentCode = PaymentCode("CC")

        val paymentRequest = CardPaymentBuilder(paymentCode, "4111111111111111").apply {
            expiryMonth(12)
            expiryYear(2026)
            securityCode("123")
        }.build()

        //Step 3: Construct transaction request.
        val transactionResultRequest = TransactionResultRequestBuilder(paymentToken).apply {
            with(paymentRequest)
        }.build()

        //Step 4: Execute payment request.
        proceedTransaction(transactionResultRequest)
    }

    //Reference: https://developer.2c2p.com/docs/sdk-method-credit-debit-card-local
    fun localCreditDebitCard() {

        //Step 1: Generate payment token.
        val paymentToken = paymentToken

        //Step 2: Construct local credit card request.
        val paymentCode = PaymentCode("KBZ")

        val paymentRequest = CardPaymentBuilder(paymentCode, "9505081000129999").apply {
            expiryMonth(12)
            expiryYear(2026)
            pin("123456")
        }.build()

        //Step 3: Construct transaction request.
        val transactionResultRequest = TransactionResultRequestBuilder(paymentToken).apply {
            with(paymentRequest)
        }.build()

        //Step 4: Execute payment request.
        proceedTransaction(transactionResultRequest)
    }

    //Reference: https://developer.2c2p.com/docs/sdk-customer-tokenization
    fun customerTokenization() {

        //Step 1: Generate payment token.
        val paymentToken = paymentToken

        //Step 2: Enable Tokenization.
        val customerTokenization = true //Enable or Disable Tokenization

        //Step 3: Construct credit card request.
        val paymentCode = PaymentCode("CC")

        val paymentRequest = CardPaymentBuilder(paymentCode, "4111111111111111").apply {
            expiryMonth(12)
            expiryYear(2026)
            securityCode("123")
            tokenize(customerTokenization)
        }.build()

        //Step 4: Construct transaction request.
        val transactionResultRequest = TransactionResultRequestBuilder(paymentToken).apply {
            with(paymentRequest)
        }.build()

        //Step 5: Execute payment request.
        proceedTransaction(transactionResultRequest)
    }

    //Reference: https://developer.2c2p.com/docs/sdk-customer-tokenization-without-authorization
    //           https://developer.2c2p.com/docs/sdk-e-wallet-tokenization-without-authorization
    fun customerTokenizationWithoutAuthorisation() {

        //Step 1: Generate payment token.
        val paymentToken = paymentToken

        //Step 2: Construct credit card request.
        val paymentCode = PaymentCode("CC")

        val paymentRequest = CardPaymentBuilder(paymentCode, "4111111111111111").apply {
            expiryMonth(12)
            expiryYear(2026)
            securityCode("123")
        }.build()

        //Step 3: Construct transaction request.
        val transactionResultRequest = TransactionResultRequestBuilder(paymentToken).apply {
            with(paymentRequest)
        }.build()

        //Step 4: Execute payment request.
        proceedTransaction(transactionResultRequest)
    }

    //Reference: https://developer.2c2p.com/docs/sdk-payment-with-customer-token
    fun customerToken() {

        //Step 1: Generate payment token.
        val paymentToken = paymentToken

        //Step 2: Set customer token.
        val customerToken = "20052010380915759367"

        //Step 3: Construct credit card request.
        val paymentCode = PaymentCode("CC")

        val paymentRequest = CustomerTokenPaymentBuilder(paymentCode, customerToken).apply {
            securityCode("123")
        }.build()

        //Step 4: Construct transaction request.
        val transactionResultRequest = TransactionResultRequestBuilder(paymentToken).apply {
            with(paymentRequest)
        }.build()

        //Step 5: Execute payment request.
        proceedTransaction(transactionResultRequest)
    }

    //Reference: https://developer.2c2p.com/docs/sdk-installment-payment-plan
    fun installmentPaymentPlan() {

        //Step 1: Generate payment token.
        val paymentToken = paymentToken

        //Step 2: Construct installment payment plan request.
        val paymentCode = PaymentCode("IPP")

        val paymentRequest = CardPaymentBuilder(paymentCode, "4111111111111111").apply {
            expiryMonth(12)
            expiryYear(2026)
            securityCode("123")
            installmentInterestType(InstallmentInterestTypeCode.Merchant)
            installmentPeriod(6)
        }.build()

        //Step 3: Construct transaction request.
        val transactionResultRequest = TransactionResultRequestBuilder(paymentToken).apply {
            with(paymentRequest)
        }.build()

        //Step 4: Execute payment request.
        proceedTransaction(transactionResultRequest)
    }

    //Reference: https://developer.2c2p.com/docs/sdk-recurring-payment-plan
    fun recurringPaymentPlan() {

        //Step 1: Generate payment token.
        val paymentToken = paymentToken

        //Step 2: Construct recurring payment plan request.
        val paymentCode = PaymentCode("CC")

        val paymentRequest = CardPaymentBuilder(paymentCode, "4111111111111111").apply {
            expiryMonth(12)
            expiryYear(2026)
            securityCode("123")
        }.build()

        //Step 3: Construct transaction request.
        val transactionResultRequest = TransactionResultRequestBuilder(paymentToken).apply {
            with(paymentRequest)
        }.build()

        //Step 4: Execute payment request.
        proceedTransaction(transactionResultRequest)
    }

    //Reference: https://developer.2c2p.com/docs/sdk-method-third-party-payment
    fun thirdPartyPayment() {

        //Step 1: Generate payment token.
        val paymentToken = paymentToken

        //Step 2: Construct third party payment request.
        val paymentCode = PaymentCode("UPOP")

        val paymentRequest = CardPaymentBuilder(paymentCode).apply {
            name("DavidBilly")
            email("davidbilly@2c2p.com")
            mobileNo("0888888888")
        }.build()

        //Step 3: Construct transaction request.
        val transactionResultRequest = TransactionResultRequestBuilder(paymentToken).apply {
            with(paymentRequest)
        }.build()

        //Step 4: Execute payment request.
        proceedTransaction(transactionResultRequest)
    }

    //Reference: https://developer.2c2p.com/docs/sdk-user-address-for-payment
    fun userAddressForPayment() {

        //Step 1: Generate payment token.
        val paymentToken = paymentToken

        //Step 2: Construct customer billing address information.
        val userBillingAddress = UserBillingAddress().apply {
            address1 = "128 Beach Road"
            address2 = "#21-04"
            address3 = "Guoco Midtown"
            city = "Singapore"
            countryCode = "SG"
            postalCode = "189773"
            state = "Singapore"
        }

        val userAddress: UserAddress = UserAddressBuilder().apply {
            userBillingAddress(userBillingAddress)
        }.build()

        //Step 3: Construct payment request and add user address into request.
        val paymentCode = PaymentCode("CC")

        val paymentRequest = CardPaymentBuilder(paymentCode, "4111111111111111").apply {
            expiryMonth(12)
            expiryYear(2026)
            securityCode("123")
            userAddress(userAddress)
        }.build()

        //Step 4: Construct transaction request.
        val transactionResultRequest = TransactionResultRequestBuilder(paymentToken).apply {
            with(paymentRequest)
        }.build()

        //Step 5: Execute payment request.
        proceedTransaction(transactionResultRequest)
    }

    //Reference: https://developer.2c2p.com/docs/sdk-online-direct-debit
    fun onlineDirectDebit() {

        //Step 1: Generate payment token.
        val paymentToken = paymentToken

        //Step 2: Construct Online Direct Debit Payment request.
        val paymentCode = PaymentCode("123", "THKTB", "ODD")

        val paymentRequest = OnlineDirectDebitBuilder(paymentCode).apply {
            name("DavidBilly")
            email("davidbilly@2c2p.com")
            mobileNo("08888888")
        }.build()

        //Step 3: Construct transaction request.
        val transactionResultRequest = TransactionResultRequestBuilder(paymentToken).apply {
            with(paymentRequest)
        }.build()

        //Step 4: Execute payment request.
        proceedTransaction(transactionResultRequest)
    }

    //Reference: https://developer.2c2p.com/docs/sdk-deep-link-payment
    fun deepLinkPayment() {

        //Step 1: Generate payment token.
        val paymentToken = paymentToken

        //Step 2: Construct Deep Link payment request.
        val paymentCode = PaymentCode("123", "THSCB", "DEEPLINK")

        val paymentRequest = DeepLinkPaymentBuilder(paymentCode).apply {
            name("DavidBilly")
            email("davidbilly@2c2p.com")
            mobileNo("0888888888")
        }.build()

        //Step 3: Construct transaction request.
        val transactionResultRequest = TransactionResultRequestBuilder(paymentToken).apply {
            with(paymentRequest)
        }.build()

        //Step 4: Execute payment request.
        proceedTransaction(transactionResultRequest)
    }

    //Reference: https://developer.2c2p.com/docs/sdk-method-internet-banking
    fun internetBanking() {

        //Step 1: Generate payment token.
        val paymentToken = paymentToken

        //Step 2: Construct Internet Banking request.
        val paymentCode = PaymentCode("123", "THUOB", "IBANKING")

        val paymentRequest = InternetBankingBuilder(paymentCode).apply {
            name("DavidBilly")
            email("davidbilly@2c2p.com")
            mobileNo("0888888888")
        }.build()

        //Step 3: Construct transaction request.
        val transactionResultRequest = TransactionResultRequestBuilder(paymentToken).apply {
            with(paymentRequest)
        }.build()

        //Step 4: Execute payment request.
        proceedTransaction(transactionResultRequest)
    }

    //Reference: https://developer.2c2p.com/docs/sdk-method-web-payment
    fun webPayment() {

        //Step 1: Generate payment token.
        val paymentToken = paymentToken

        //Step 2: Construct Web Payment request.
        val paymentCode = PaymentCode("123", "THBBL", "WEBPAY")

        val paymentRequest = WebPaymentBuilder(paymentCode).apply {
            name("DavidBilly")
            email("davidbilly@2c2p.com")
            mobileNo("0888888888")
        }.build()

        //Step 3: Construct transaction request.
        val transactionResultRequest = TransactionResultRequestBuilder(paymentToken).apply {
            with(paymentRequest)
        }.build()

        //Step 4: Execute payment request.
        proceedTransaction(transactionResultRequest)
    }

    //Reference: https://developer.2c2p.com/docs/sdk-method-pay-at-counter
    fun payAtCounter() {

        //Step 1: Generate payment token.
        val paymentToken = paymentToken

        //Step 2: Construct Pay At Counter request.
        val paymentCode = PaymentCode("123", "BIGC", "OVERTHECOUNTER")

        val paymentRequest = PayAtCounterBuilder(paymentCode).apply {
            name("DavidBilly")
            email("davidbilly@2c2p.com")
            mobileNo("0888888888")
        }.build()

        //Step 3: Construct transaction request.
        val transactionResultRequest = TransactionResultRequestBuilder(paymentToken).apply {
            with(paymentRequest)
        }.build()

        //Step 4: Execute payment request.
        proceedTransaction(transactionResultRequest)
    }

    //Reference: https://developer.2c2p.com/docs/sdk-method-self-service-machines
    fun selfServiceMachines() {

        //Step 1: Generate payment token.
        val paymentToken = paymentToken

        //Step 2: Construct Self Service Machine request.
        val paymentCode = PaymentCode("123", "THUOB", "ATM")

        val paymentRequest = SelfServiceMachineBuilder(paymentCode).apply {
            name("DavidBilly")
            email("davidbilly@2c2p.com")
            mobileNo("0888888888")
        }.build()

        //Step 3: Construct transaction request.
        val transactionResultRequest = TransactionResultRequestBuilder(paymentToken).apply {
            with(paymentRequest)
        }.build()

        //Step 4: Execute payment request.
        proceedTransaction(transactionResultRequest)
    }

    //Reference: https://developer.2c2p.com/docs/sdk-method-qr-payment
    fun qrPayment() {

        //Step 1: Generate payment token.
        val paymentToken = paymentToken

        //Step 2: Construct QR request.
        val paymentCode = PaymentCode("VEMVQR")

        val paymentRequest = QRPaymentBuilder(paymentCode).apply {
            type(QRTypeCode.URL)
            name("DavidBilly")
            email("davidbilly@2c2p.com")
            mobileNo("0888888888")
        }.build()

        //Step 3: Construct transaction request.
        val transactionResultRequest = TransactionResultRequestBuilder(paymentToken).apply {
            with(paymentRequest)
        }.build()

        //Step 4: Execute payment request.
        proceedTransaction(transactionResultRequest)
    }

    //Reference: https://developer.2c2p.com/docs/sdk-method-buy-now-pay-later
    fun buyNowPayLater() {

        //Step 1: Generate payment token.
        val paymentToken = paymentToken

        //Step 2: Construct buy now pay later request.
        val paymentCode = PaymentCode("GRABBNPL")

        val paymentRequest = BuyNowPayLaterPaymentBuilder(paymentCode).apply {
            name("DavidBilly")
            email("davidbilly@2c2p.com")
        }.build()

        //Step 3: Construct transaction request.
        val transactionResultRequest = TransactionResultRequestBuilder(paymentToken).apply {
            with(paymentRequest)
        }.build()

        //Step 4: Execute payment request.
        proceedTransaction(transactionResultRequest)
    }

    //Reference: https://developer.2c2p.com/docs/sdk-method-gcash
    //           https://developer.2c2p.com/docs/sdk-method-grab-pay
    //           https://developer.2c2p.com/docs/sdk-method-touch-n-go
    //           https://developer.2c2p.com/docs/sdk-method-true-money-wallet
    //           https://developer.2c2p.com/docs/sdk-method-wave-pay
    //           https://developer.2c2p.com/docs/sdk-method-ok-dollar-wallet
    //           https://developer.2c2p.com/docs/sdk-method-boost-wallet
    //           https://developer.2c2p.com/docs/sdk-method-master-pass
    //           https://developer.2c2p.com/docs/sdk-method-paypal-wallet
    //           https://developer.2c2p.com/docs/sdk-method-m-pitesan
    //           https://developer.2c2p.com/docs/sdk-method-spa-wallet
    //           https://developer.2c2p.com/docs/sdk-method-kbzpay
    //           https://developer.2c2p.com/docs/sdk-method-cb-pay
    //           https://developer.2c2p.com/docs/sdk-method-ovo
    //           https://developer.2c2p.com/docs/sdk-method-linkaja
    //           https://developer.2c2p.com/docs/sdk-method-alipay
    //           https://developer.2c2p.com/docs/sdk-references-handle-deeplink-payment-flow-by-pgw-sdk-helper
    fun digitalPayment() {

        //Step 1: Generate payment token.
        val paymentToken = paymentToken

        //Step 2: Construct e-wallet request.
        val paymentCode = PaymentCode("GRAB")

        val paymentRequest = DigitalPaymentBuilder(paymentCode).apply {
            name("DavidBilly")
            email("davidbilly@2c2p.com")
            mobileNo("0888888888")
        }.build()

        //Step 3: Construct transaction request.
        val transactionResultRequest = TransactionResultRequestBuilder(paymentToken).apply {
            with(paymentRequest)
        }.build()

        //Step 4: Execute payment request.
        proceedTransaction(transactionResultRequest)
    }

    //Reference: https://developer.2c2p.com/docs/sdk-method-line-pay
    fun linePay() {

        //Step 1: Generate payment token.
        val paymentToken = paymentToken

        //Step 2: Construct e-wallet request.
        val paymentCode = PaymentCode("LINE")

        val paymentRequest = DigitalPaymentBuilder(paymentCode).apply {
            name("DavidBilly")
            email("davidbilly@2c2p.com")
            mobileNo("0888888888")
        }.build()

        //Step 3: Construct transaction request.
        val transactionResultRequest = TransactionResultRequestBuilder(paymentToken).apply {
            with(paymentRequest)
        }.build()

        //Step 4: Execute payment request.
        proceedTransaction(transactionResultRequest)
    }

    //Reference: https://developer.2c2p.com/docs/sdk-method-google-pay
    @OptIn(DelicateCoroutinesApi::class)
    fun googlePay() = GlobalScope.launch(Dispatchers.Main) {

        //Step 1: Generate payment token.
        val paymentToken = paymentToken

        val paymentOptionDetailResponse = GlobalScope.async {

            suspendCoroutine { continuation ->

                //Step 2: Construct payment option details request.
                val paymentOptionDetailRequest = PaymentOptionDetailRequest(paymentToken).apply {
                    categoryCode = PaymentChannelCode.Category.DigitalPayment
                    groupCode = PaymentChannelCode.Group.CardWalletPayment
                }

                //Step 3: Retrieve payment option details response.
                PGWSDK.getInstance().paymentOptionDetail(paymentOptionDetailRequest, object : APIResponseCallback<PaymentOptionDetailResponse> {

                    override fun onResponse(response: PaymentOptionDetailResponse) {

                        continuation.resumeWith(Result.success(response))
                    }

                    override fun onFailure(error: Throwable) {

                        continuation.resumeWith(Result.success(PaymentOptionDetailResponse()))
                    }
                })
            }
        }.await()

        //Step 2: Retrieve payment provider info from Payment Option Details API.
        val paymentProvider = paymentOptionDetailResponse.channels.find {
            it.context.code.channelCode.equals("GOOGLEPAY", ignoreCase = true)
        }?.context?.info?.paymentProvider

        paymentProvider?.let {

            val googleEnvironment = WalletConstants.ENVIRONMENT_TEST

            //Step 3: Construct google pay token request.
            val paymentProviderRequest = PaymentProviderBuilder(activityReference?.get()).apply {
                paymentProvider(paymentProvider)
            }.build()

            //Verify Google Pay are support on device (Optional)
            val supportGooglePayPaymentResponse = GlobalScope.async {

                suspendCoroutine { continuation ->

                    PGWSDKHelper.getInstance().supportGooglePayPayment(googleEnvironment, paymentProviderRequest, object : PaymentResultResponseCallback<GooglePayPaymentResultResponse> {

                        override fun onResponse(response: GooglePayPaymentResultResponse) {

                            continuation.resumeWith(Result.success(response))
                        }

                        override fun onFailure(error: Throwable) {

                            continuation.resumeWith(Result.success(GooglePayPaymentResultResponse()))
                        }
                    })
                }
            }.await()

            if (supportGooglePayPaymentResponse.responseCode == GooglePayPaymentResponseCode.SupportedDevice) {

                PGWSDKHelper.getInstance().proceedGooglePayPayment(googleEnvironment, paymentProviderRequest, object : PaymentResultResponseCallback<GooglePayPaymentResultResponse> {

                    override fun onResponse(response: GooglePayPaymentResultResponse) {

                        if (response.responseCode == GooglePayPaymentResponseCode.TokenGeneratedSuccess) {

                            //Step 4: Construct google pay payment request.
                            val paymentCode = PaymentCode("GOOGLEPAY")

                            val paymentRequest = DigitalPaymentBuilder(paymentCode).apply {
                                name("DavidBilly")
                                email("davidbilly@2c2p.com")
                                token(response.token)
                            }.build()

                            //Step 5: Construct transaction request.
                            val transactionResultRequest = TransactionResultRequestBuilder(paymentToken).apply {
                                with(paymentRequest)
                            }.build()

                            //Step 6: Execute payment request.
                            proceedTransaction(transactionResultRequest)
                        } else {

                            //Get error response and display error.
                            showAlertDialog(Constants.apiDoPayment.first, StringHelper.toJson(response))
                        }
                    }

                    override fun onFailure(error: Throwable) {

                        //Get error response and display error.
                        showAlertDialog(Constants.apiDoPayment.first, "Error: ${error.message ?: ""}")
                    }
                })
            } else {

                showAlertDialog(Constants.paymentGooglePay.first, StringHelper.toJson(supportGooglePayPaymentResponse))
            }
        } ?: run {

            showAlertDialog(Constants.paymentGooglePay.first, Constants.errorGooglePayNotEnabled)
        }
    }

    //Reference: https://developer.2c2p.com/docs/sdk-card-loyalty-point-payment
    fun cardLoyaltyPointPayment() {

        //Step 1: Generate payment token.
        val paymentToken = paymentToken

        //Step 2: Construct loyalty point payment request.
        val paymentCode = PaymentCode("CC")

        val loyaltyPoints = arrayListOf<LoyaltyPoint>()
        val rewards = arrayListOf<LoyaltyPointReward>()

        //Loyalty point reward info can be retrieve from Loyalty Point Info API
        val reward = LoyaltyPointReward().apply {
            id = "1792e2b5-8b41-4712-9b44-4c857ce90c3e"
            quantity = 1.0
        }
        rewards.add(reward)

        //Loyalty point info can be retrieve from Loyalty Point Info API
        val loyaltyPoint = LoyaltyPoint().apply {
            providerId = "DGC"
            redeemAmount = 1.00
            this.rewards = rewards
        }
        loyaltyPoints.add(loyaltyPoint)

        val paymentRequest = LoyaltyPointPaymentBuilder(paymentCode).apply {
            cardNo("4111111111111111")
            expiryMonth(12)
            expiryYear(2026)
            securityCode("123")
            loyaltyPoints(loyaltyPoints)
        }.build()

        //Step 3: Construct transaction request.
        val transactionResultRequest = TransactionResultRequestBuilder(paymentToken).apply {
            with(paymentRequest)
        }.build()

        //Step 4: Execute payment request.
        proceedTransaction(transactionResultRequest)
    }

    //Reference: https://developer.2c2p.com/docs/sdk-method-zalopay
    fun zaloPay() {

        //Step 1: Generate payment token.
        val paymentToken = paymentToken

        //Step 2: Construct e-wallet request.
        val paymentCode = PaymentCode("ZALOPAY")

        val paymentRequest = DigitalPaymentBuilder(paymentCode).apply {
            name("DavidBilly")
            email("davidbilly@2c2p.com")
            mobileNo("0888888888")
        }.build()

        //Step 3: Construct transaction request.
        val transactionResultRequest = TransactionResultRequestBuilder(paymentToken).apply {
            with(paymentRequest)
        }.build()

        //Step 4: Execute payment request.
        proceedTransaction(transactionResultRequest)
    }

    //Reference: https://developer.2c2p.com/docs/sdk-method-triplea
    fun cryptocurrency() {

        //Step 1: Generate payment token.
        val paymentToken = paymentToken

        //Step 2: Construct digital currency request.
        val paymentCode = PaymentCode("TRIPLEA")

        val paymentRequest = DigitalCurrencyBuilder(paymentCode).apply {
            name("DavidBilly")
            email("davidbilly@2c2p.com")
            mobileNo("0888888888")
        }.build()

        //Step 3: Construct transaction request.
        val transactionResultRequest = TransactionResultRequestBuilder(paymentToken).apply {
            with(paymentRequest)
        }.build()

        //Step 4: Execute payment request.
        proceedTransaction(transactionResultRequest)
    }

    //Reference: https://developer.2c2p.com/docs/sdk-method-web-payment-card-wpc
    fun webPaymentCard() {

        //Step 1: Generate payment token.
        val paymentToken = paymentToken

        //Step 2: Construct web payment card request.
        val paymentCode = PaymentCode("123", "VNABB", "WEBPAY")

        val paymentRequest = WebPaymentBuilder(paymentCode).apply {
            cardNo("9704160000000018")
            expiryMonth(12)
            expiryYear(2026)
            issuedMonth(1)
            issuedYear(2023)
            securityCode("123")
            name("DavidBilly")
            email("davidbilly@2c2p.com")
            mobileNo("0888888888")
        }.build()

        //Step 3: Construct transaction request.
        val transactionResultRequest = TransactionResultRequestBuilder(paymentToken).apply {
            with(paymentRequest)
        }.build()

        //Step 4: Execute payment request.
        proceedTransaction(transactionResultRequest)
    }
}