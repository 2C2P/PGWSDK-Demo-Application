//
//  InfoAPI.swift
//  PGWSDKDemoApplication
//
//  Created by DavidBilly on 1/6/25.
//

import Foundation
import PGW

@objc class InfoApi: NSObject {
    
    @objc static func clientId() {
        
        ContentView.showAlertDialog(Constants.apiClientId.0, PGWSDK.shared.clientId())
    }
    
    @objc static func configuration() {
 
        ContentView.showAlertDialog(Constants.apiConfiguration.0, PGWSDK.shared.configuration())
    }
    
    //Reference: https://developer.2c2p.com/docs/sdk-api-payment-option
    @objc static func paymentOption() {
        
        //Step 1: Generate payment token.
        let paymentToken: String = paymentToken
         
        //Step 2: Construct payment option request.
        let paymentOptionRequest: PaymentOptionRequest = PaymentOptionRequest(paymentToken: paymentToken)
         
        //Step 3: Retrieve payment options response.
        PGWSDK.shared.paymentOption(paymentOptionRequest: paymentOptionRequest, { (response: PaymentOptionResponse) in
         
            if response.responseCode == APIResponseCode.APISuccess {

                //Read payment option response.
            } else {

                //Get error response and display error.
            }
            
            ContentView.showAlertDialog(Constants.apiPaymentOption.0, PaymentOptionResponse.parse(response))
        }) { (error: NSError) in
         
            //Get error response and display error.
            ContentView.showAlertDialog(Constants.apiPaymentOption.0, "Error: \(error.domain)")
        }
    }

    //Reference: https://developer.2c2p.com/docs/sdk-api-payment-option-details
    @objc static func paymentOptionDetail() {

        //Step 1: Generate payment token.
        let paymentToken: String = paymentToken
         
        //Step 2: Construct payment option details request.
        let paymentOptionDetailRequest: PaymentOptionDetailRequest = PaymentOptionDetailRequest(paymentToken: paymentToken)
        paymentOptionDetailRequest.categoryCode = PaymentChannelCode.Category.GlobalCardPayment
        paymentOptionDetailRequest.groupCode = PaymentChannelCode.Group.CreditCard
         
        //Step 3: Retrieve payment option details response.
        PGWSDK.shared.paymentOptionDetail(paymentOptionDetailRequest: paymentOptionDetailRequest, { (response: PaymentOptionDetailResponse) in
                                                                                                   
            if response.responseCode == APIResponseCode.APISuccess {

                //Read Payment option details response.
            } else {

                //Get error response and display error.
            }
            
            ContentView.showAlertDialog(Constants.apiPaymentOptionDetail.0, PaymentOptionDetailResponse.parse(response))
        }) { (error: NSError) in
            
            //Get error response and display error.
            ContentView.showAlertDialog(Constants.apiPaymentOptionDetail.0, "Error: \(error.domain)")
        }
    }

    //Reference: https://developer.2c2p.com/docs/sdk-api-customer-tokens-information
    @objc static func customerTokenInfo() {

        //Step 1: Generate payment token.
        let paymentToken: String = paymentToken
         
        //Step 2: Construct customer token info request.
        let customerTokenInfoRequest: CustomerTokenInfoRequest = CustomerTokenInfoRequest(paymentToken: paymentToken)
                  
        //Step 3: Retrieve customer token info response.
        PGWSDK.shared.customerTokenInfo(customerTokenInfoRequest: customerTokenInfoRequest, { (response: CustomerTokenInfoResponse) in
         
            if response.responseCode == APIResponseCode.APISuccess {

                //Read customer token info response.
            } else {

                //Get error response and display error.
            }
            
            ContentView.showAlertDialog(Constants.apiCustomerTokenInfo.0, CustomerTokenInfoResponse.parse(response))
        }) { (error: NSError) in
         
            //Get error response and display error.
            ContentView.showAlertDialog(Constants.apiCustomerTokenInfo.0, "Error: \(error.domain)")
        }
    }

    //Reference: https://developer.2c2p.com/docs/sdk-api-exchange-rate
    @objc static func exchangeRate() {

        //Step 1: Generate payment token.
        let paymentToken: String = paymentToken
         
        //Step 2: Construct exchange rate info request.
        let exchangeRateRequest: ExchangeRateRequest = ExchangeRateRequest(paymentToken: paymentToken)
        exchangeRateRequest.bin = "411111"
                 
        //Step 3: Retrieve exchange rate response.
        PGWSDK.shared.exchangeRate(exchangeRateRequest: exchangeRateRequest, { (response: ExchangeRateResponse) in
                                                                              
            if response.responseCode == APIResponseCode.APISuccess {

                //Read exchange rate response.
            } else {

                //Get error response and display error.
            }
            
            ContentView.showAlertDialog(Constants.apiExchangeRate.0, ExchangeRateResponse.parse(response))
        }) { (error: NSError) in
            
            //Get error response and display error.
            ContentView.showAlertDialog(Constants.apiExchangeRate.0, "Error: \(error.domain)")
        }
    }

    //Reference: https://developer.2c2p.com/docs/sdk-api-user-preference
    @objc static func userPreference() {

        //Step 1: Generate payment token.
        let paymentToken: String = paymentToken
         
        //Step 2: Construct user preference request.
        let userPreferenceRequest: UserPreferenceRequest = UserPreferenceRequest(paymentToken: paymentToken)
                 
        //Step 3: Retrieve user preference response.
        PGWSDK.shared.userPreference(userPreferenceRequest: userPreferenceRequest, { (response: UserPreferenceResponse) in
         
            if response.responseCode == APIResponseCode.APISuccess {

                //Read user preference response.
            } else {

                //Get error response and display error.
            }
            
            ContentView.showAlertDialog(Constants.apiUserPreference.0, UserPreferenceResponse.parse(response))
        }) { (error: NSError) in
            
            //Get error response and display error.
            ContentView.showAlertDialog(Constants.apiUserPreference.0, "Error: \(error.domain)")
        }
    }

    //Reference: https://developer.2c2p.com/docs/api-sdk-transaction-status-inquiry
    @objc static func transactionStatus(_ token: String) {

        //Step 1: Generate payment token.
        let paymentToken: String = token.isEmpty ? paymentToken : token
         
        //Step 2: Construct transaction status inquiry request.
        let transactionStatusRequest: TransactionStatusRequest = TransactionStatusRequest(paymentToken: paymentToken)
        transactionStatusRequest.additionalInfo = true
                 
        //Step 3: Retrieve transaction status inquiry response.
        PGWSDK.shared.transactionStatus(transactionStatusRequest: transactionStatusRequest, { (response: TransactionStatusResponse) in
                     
            if response.responseCode == APIResponseCode.TransactionNotFound || response.responseCode == APIResponseCode.TransactionCompleted {

                //Read transaction status inquiry response.
            } else {

                //Get error response and display error.
            }
            
            ContentView.showAlertDialog(Constants.apiTransactionStatus.0, TransactionStatusResponse.parse(response))
        }) { (error: NSError) in
            
            //Get error response and display error.
            ContentView.showAlertDialog(Constants.apiTransactionStatus.0, "Error: \(error.domain)")
        }
    }

    //Reference: https://developer.2c2p.com/docs/sdk-api-pgw-initialization
    @objc static func systemInitialization() {

        //Step 1: Construct system initialization request.
        let systemInitializationRequest: SystemInitializationRequest = SystemInitializationRequest()
                 
        //Step 2: Retrieve system initialization response.
        PGWSDK.shared.systemInitialization(systemInitializationRequest: systemInitializationRequest, { (response: SystemInitializationResponse) in
                                                                                                      
            if response.responseCode == APIResponseCode.APISuccess {

                //Read system initialization response.
            } else {

                //Get error response and display error.
            }
            
            ContentView.showAlertDialog(Constants.apiSystemInitialization.0, SystemInitializationResponse.parse(response))
        }) { (error: NSError) in
            
             //Get error response and display error.
            ContentView.showAlertDialog(Constants.apiSystemInitialization.0, "Error: \(error.domain)")
        }
    }

    //Reference: https://developer.2c2p.com/docs/sdk-api-payment-notification
    @objc static func paymentNotification() {

        //Step 1: Generate payment token.
        let paymentToken: String = paymentToken
         
        //Step 2: Construct payment notification request.
        let paymentNotificationRequest: PaymentNotificationRequest = PaymentNotificationRequest(paymentToken: paymentToken)
        paymentNotificationRequest.platform = PaymentNotificationPlatformCode.Email
        paymentNotificationRequest.recipientId = "davidbilly@2c2p.com"
        paymentNotificationRequest.recipientName = "DavidBilly"
                 
        //Step 3: Retrieve payment notification response.
        PGWSDK.shared.paymentNotification(paymentNotificationRequest: paymentNotificationRequest, { (response: PaymentNotificationResponse) in
         
            if response.responseCode == APIResponseCode.APISuccess {

                //Read payment notification response.
            } else {

                //Get error response and display error.
            }
            
            ContentView.showAlertDialog(Constants.apiPaymentNotification.0, PaymentNotificationResponse.parse(response))
        }) { (error: NSError) in
            
            //Get error response and display error.
            ContentView.showAlertDialog(Constants.apiPaymentNotification.0, "Error: \(error.domain)")
        }
    }

    //Reference: https://developer.2c2p.com/docs/sdk-api-cancel-transaction
    @objc static func cancelTransaction() {

        //Step 1: Generate payment token.
        let paymentToken: String = paymentToken
         
        //Step 2: Construct cancel transaction request.
        let cancelTransactionRequest: CancelTransactionRequest = CancelTransactionRequest(paymentToken: paymentToken)
                 
        //Step 3: Retrieve cancel transaction response.
        PGWSDK.shared.cancelTransaction(cancelTransactionRequest: cancelTransactionRequest, { (response: CancelTransactionResponse) in
         
            if response.responseCode == APIResponseCode.APISuccess {

                //Read cancel transaction response.
            } else {

                //Get error response and display error.
            }
            
            ContentView.showAlertDialog(Constants.apiCancelTransaction.0, CancelTransactionResponse.parse(response))
        }) { (error: NSError) in
         
            //Get error response and display error.
            ContentView.showAlertDialog(Constants.apiCancelTransaction.0, "Error: \(error.domain)")
        }
    }

    //Reference: https://developer.2c2p.com/docs/sdk-api-loyalty-point-information
    @objc static func loyaltyPointInfo() {

        //Step 1: Generate payment token.
        let paymentToken: String = paymentToken
         
        //Step 2: Construct loyalty point info request.
        let loyaltyPointInfoRequest: LoyaltyPointInfoRequest = LoyaltyPointInfoRequest(paymentToken: paymentToken)
        loyaltyPointInfoRequest.providerId = "DGC"
                  
        //Step 3: Retrieve loyalty point info.
        PGWSDK.shared.loyaltyPointInfo(loyaltyPointInfoRequest: loyaltyPointInfoRequest, { (response: LoyaltyPointInfoResponse) in
         
            if response.responseCode == APIResponseCode.APISuccess {

                //Read loyalty point info response.
            } else {

                //Get error response and display error.
            }
            
            ContentView.showAlertDialog(Constants.apiLoyaltyPointInfo.0, LoyaltyPointInfoResponse.parse(response))
        }) { (error: NSError) in
         
            //Get error response and display error.
            ContentView.showAlertDialog(Constants.apiLoyaltyPointInfo.0, "Error: \(error.domain)")
        }
    }
}
