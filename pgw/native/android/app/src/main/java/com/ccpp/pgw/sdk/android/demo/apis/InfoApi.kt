package com.ccpp.pgw.sdk.android.demo.apis

import com.ccpp.pgw.sdk.android.callback.APIResponseCallback
import com.ccpp.pgw.sdk.android.core.PGWSDK
import com.ccpp.pgw.sdk.android.demo.Constants
import com.ccpp.pgw.sdk.android.demo.MainActivity.Companion.paymentToken
import com.ccpp.pgw.sdk.android.demo.MainActivity.Companion.showAlertDialog
import com.ccpp.pgw.sdk.android.demo.helper.StringHelper
import com.ccpp.pgw.sdk.android.enums.APIResponseCode
import com.ccpp.pgw.sdk.android.enums.PaymentChannelCode
import com.ccpp.pgw.sdk.android.enums.PaymentNotificationPlatformCode
import com.ccpp.pgw.sdk.android.model.api.CancelTransactionRequest
import com.ccpp.pgw.sdk.android.model.api.CancelTransactionResponse
import com.ccpp.pgw.sdk.android.model.api.CustomerTokenInfoRequest
import com.ccpp.pgw.sdk.android.model.api.CustomerTokenInfoResponse
import com.ccpp.pgw.sdk.android.model.api.ExchangeRateRequest
import com.ccpp.pgw.sdk.android.model.api.ExchangeRateResponse
import com.ccpp.pgw.sdk.android.model.api.LoyaltyPointInfoRequest
import com.ccpp.pgw.sdk.android.model.api.LoyaltyPointInfoResponse
import com.ccpp.pgw.sdk.android.model.api.PaymentNotificationRequest
import com.ccpp.pgw.sdk.android.model.api.PaymentNotificationResponse
import com.ccpp.pgw.sdk.android.model.api.PaymentOptionDetailRequest
import com.ccpp.pgw.sdk.android.model.api.PaymentOptionDetailResponse
import com.ccpp.pgw.sdk.android.model.api.PaymentOptionRequest
import com.ccpp.pgw.sdk.android.model.api.PaymentOptionResponse
import com.ccpp.pgw.sdk.android.model.api.SystemInitializationRequest
import com.ccpp.pgw.sdk.android.model.api.SystemInitializationResponse
import com.ccpp.pgw.sdk.android.model.api.TransactionStatusRequest
import com.ccpp.pgw.sdk.android.model.api.TransactionStatusResponse
import com.ccpp.pgw.sdk.android.model.api.UserPreferenceRequest
import com.ccpp.pgw.sdk.android.model.api.UserPreferenceResponse

/**
 * Created by DavidBilly PK on 23/12/24.
 */
object InfoApi {

    fun clientId() {

        showAlertDialog(Constants.apiClientId.first, PGWSDK.getInstance().clientId)
    }

    fun configuration() {

        showAlertDialog(Constants.apiConfiguration.first, PGWSDK.getInstance().configuration)
    }

    //Reference: https://developer.2c2p.com/docs/sdk-api-payment-option
    fun paymentOption() {

        //Step 1: Generate payment token.
        val paymentToken = paymentToken

        //Step 2: Construct payment option request.
        val paymentOptionRequest = PaymentOptionRequest(paymentToken)

        //Step 3: Retrieve payment options response.
        PGWSDK.getInstance().paymentOption(paymentOptionRequest, object : APIResponseCallback<PaymentOptionResponse> {

            override fun onResponse(response: PaymentOptionResponse) {

                if (response.responseCode == APIResponseCode.APISuccess) {

                    //Read payment option response.
                } else {

                    //Get error response and display error.
                }

                showAlertDialog(Constants.apiPaymentOption.first, StringHelper.toJson(response))
            }

            override fun onFailure(error: Throwable) {

                //Get error response and display error.
                showAlertDialog(Constants.apiPaymentOption.first, "Error: ${error.message ?: ""}")
            }
        })
    }

    //Reference: https://developer.2c2p.com/docs/sdk-api-payment-option-details
    fun paymentOptionDetail() {

        //Step 1: Generate payment token.
        val paymentToken = paymentToken

        //Step 2: Construct payment option details request.
        val paymentOptionDetailRequest = PaymentOptionDetailRequest(paymentToken).apply {
            categoryCode = PaymentChannelCode.Category.GlobalCardPayment
            groupCode = PaymentChannelCode.Group.CreditCard
        }

        //Step 3: Retrieve payment option details response.
        PGWSDK.getInstance().paymentOptionDetail(paymentOptionDetailRequest, object : APIResponseCallback<PaymentOptionDetailResponse> {

            override fun onResponse(response: PaymentOptionDetailResponse) {

                if (response.responseCode == APIResponseCode.APISuccess) {

                    //Read Payment option details response.
                } else {

                    //Get error response and display error.
                }

                showAlertDialog(Constants.apiPaymentOptionDetail.first, StringHelper.toJson(response))
            }

            override fun onFailure(error: Throwable) {

                //Get error response and display error.
                showAlertDialog(Constants.apiPaymentOptionDetail.first, "Error: ${error.message ?: ""}")
            }
        })
    }

    //Reference: https://developer.2c2p.com/docs/sdk-api-customer-tokens-information
    fun customerTokenInfo() {

        //Step 1: Generate payment token.
        val paymentToken = paymentToken

        //Step 2: Construct customer token info request.
        val customerTokenInfoRequest = CustomerTokenInfoRequest(paymentToken)

        //Step 3: Retrieve customer token info response.
        PGWSDK.getInstance().customerTokenInfo(customerTokenInfoRequest, object : APIResponseCallback<CustomerTokenInfoResponse> {

            override fun onResponse(response: CustomerTokenInfoResponse) {

                if (response.responseCode == APIResponseCode.APISuccess) {

                    //Read customer token info response.
                } else {

                    //Get error response and display error.
                }

                showAlertDialog(Constants.apiCustomerTokenInfo.first, StringHelper.toJson(response))
            }

            override fun onFailure(error: Throwable) {

                //Get error response and display error.
                showAlertDialog(Constants.apiCustomerTokenInfo.first, "Error: ${error.message ?: ""}")
            }
        })
    }

    //Reference: https://developer.2c2p.com/docs/sdk-api-exchange-rate
    fun exchangeRate() {

        //Step 1: Generate payment token.
        val paymentToken = paymentToken

        //Step 2: Construct exchange rate request.
        val exchangeRateRequest = ExchangeRateRequest(paymentToken).apply {
            bin = "411111"
        }

        //Step 3: Retrieve exchange rate response.
        PGWSDK.getInstance().exchangeRate(exchangeRateRequest, object : APIResponseCallback<ExchangeRateResponse> {

            override fun onResponse(response: ExchangeRateResponse) {

                if (response.responseCode == APIResponseCode.APISuccess) {

                    //Read exchange rate response.
                } else {

                    //Get error response and display error.
                }

                showAlertDialog(Constants.apiExchangeRate.first, StringHelper.toJson(response))
            }

            override fun onFailure(error: Throwable) {

                //Get error response and display error.
                showAlertDialog(Constants.apiExchangeRate.first, "Error: ${error.message ?: ""}")
            }
        })
    }

    //Reference: https://developer.2c2p.com/docs/sdk-api-user-preference
    fun userPreference() {

        //Step 1: Generate payment token.
        val paymentToken = paymentToken

        //Step 2: Construct user preference request.
        val userPreferenceRequest = UserPreferenceRequest(paymentToken)

        //Step 3: Retrieve user preference response.
        PGWSDK.getInstance().userPreference(userPreferenceRequest, object : APIResponseCallback<UserPreferenceResponse> {

            override fun onResponse(response: UserPreferenceResponse) {

                if (response.responseCode == APIResponseCode.APISuccess) {

                    //Read user preference response.
                } else {

                    //Get error response and display error.
                }

                showAlertDialog(Constants.apiUserPreference.first, StringHelper.toJson(response))
            }

            override fun onFailure(error: Throwable) {

                //Get error response and display error.
                showAlertDialog(Constants.apiUserPreference.first, "Error: ${error.message ?: ""}")
            }
        })
    }

    //Reference: https://developer.2c2p.com/docs/api-sdk-transaction-status-inquiry
    fun transactionStatus(token: String) {

        //Step 1: Generate payment token.
        val paymentToken = token

        //Step 2: Construct transaction status inquiry request.
        val transactionStatusRequest = TransactionStatusRequest(paymentToken).apply {
            additionalInfo = true
        }

        //Step 3: Retrieve transaction status inquiry response.
        PGWSDK.getInstance().transactionStatus(transactionStatusRequest, object : APIResponseCallback<TransactionStatusResponse> {

            override fun onResponse(response: TransactionStatusResponse) {

                if (response.responseCode == APIResponseCode.TransactionNotFound || response.responseCode == APIResponseCode.TransactionCompleted) {

                    //Read transaction status inquiry response.
                } else {

                    //Get error response and display error.
                }

                showAlertDialog(Constants.apiTransactionStatus.first, StringHelper.toJson(response))
            }

            override fun onFailure(error: Throwable) {

                //Get error response and display error.
                showAlertDialog(Constants.apiTransactionStatus.first, "Error: ${error.message ?: ""}")
            }
        })
    }

    //Reference: https://developer.2c2p.com/docs/sdk-api-pgw-initialization
    fun systemInitialization() {

        //Step 1: Construct system initialization request.
        val systemInitializationRequest = SystemInitializationRequest()

        //Step 2: Retrieve system initialization response.
        PGWSDK.getInstance().systemInitialization(systemInitializationRequest, object : APIResponseCallback<SystemInitializationResponse> {

            override fun onResponse(response: SystemInitializationResponse) {

                if (response.responseCode == APIResponseCode.APISuccess) {

                    //Read system initialization response.
                } else {

                    //Get error response and display error.
                }

                showAlertDialog(Constants.apiSystemInitialization.first, StringHelper.toJson(response))
            }

            override fun onFailure(error: Throwable) {

                //Get error response and display error.
                showAlertDialog(Constants.apiSystemInitialization.first, "Error: ${error.message ?: ""}")
            }
        })
    }

    //Reference: https://developer.2c2p.com/docs/sdk-api-payment-notification
    fun paymentNotification() {

        //Step 1: Generate payment token.
        val paymentToken = paymentToken

        //Step 2: Construct payment notification request.
        val paymentNotificationRequest = PaymentNotificationRequest(paymentToken).apply {
            platform = PaymentNotificationPlatformCode.Email
            recipientId = "davidbilly@2c2p.com"
            recipientName = "DavidBilly"
        }

        //Step 3: Retrieve payment notification response.
        PGWSDK.getInstance().paymentNotification(paymentNotificationRequest, object : APIResponseCallback<PaymentNotificationResponse> {

            override fun onResponse(response: PaymentNotificationResponse) {

                if (response.responseCode == APIResponseCode.APISuccess) {

                    //Read payment notification response.
                } else {

                    //Get error response and display error.
                }

                showAlertDialog(Constants.apiPaymentNotification.first, StringHelper.toJson(response))
            }

            override fun onFailure(error: Throwable) {

                //Get error response and display error.
                showAlertDialog(Constants.apiPaymentNotification.first, "Error: ${error.message ?: ""}")
            }
        })
    }

    //Reference: https://developer.2c2p.com/docs/sdk-api-cancel-transaction
    fun cancelTransaction() {

        //Step 1: Generate payment token.
        val paymentToken = paymentToken

        //Step 2: Construct cancel transaction request.
        val cancelTransactionRequest = CancelTransactionRequest(paymentToken)

        //Step 3: Retrieve cancel transaction response.
        PGWSDK.getInstance().cancelTransaction(cancelTransactionRequest, object : APIResponseCallback<CancelTransactionResponse> {

            override fun onResponse(response: CancelTransactionResponse) {

                if (response.responseCode == APIResponseCode.APISuccess) {

                    //Read cancel transaction response.
                } else {

                    //Get error response and display error.
                }

                showAlertDialog(Constants.apiCancelTransaction.first, StringHelper.toJson(response))
            }

            override fun onFailure(error: Throwable) {

                //Get error response and display error.
                showAlertDialog(Constants.apiCancelTransaction.first, "Error: ${error.message ?: ""}")
            }
        })
    }

    //Reference: https://developer.2c2p.com/docs/sdk-api-loyalty-point-information
    fun loyaltyPointInfo() {

        //Step 1: Generate payment token.
        val paymentToken = paymentToken

        //Step 2: Construct loyalty point info request.
        val loyaltyPointInfoRequest = LoyaltyPointInfoRequest(paymentToken).apply {
            providerId = "DGC"
        }

        //Step 3: Retrieve loyalty point info.
        PGWSDK.getInstance().loyaltyPointInfo(loyaltyPointInfoRequest, object : APIResponseCallback<LoyaltyPointInfoResponse> {

            override fun onResponse(response: LoyaltyPointInfoResponse) {

                if (response.responseCode == APIResponseCode.APISuccess) {

                    //Read loyalty point info response.
                } else {

                    //Get error response and display error.
                }

                showAlertDialog(Constants.apiLoyaltyPointInfo.first, StringHelper.toJson(response))
            }

            override fun onFailure(error: Throwable) {

                //Get error response and display error.
                showAlertDialog(Constants.apiLoyaltyPointInfo.first, "Error: ${error.message ?: ""}")
            }
        })
    }
}