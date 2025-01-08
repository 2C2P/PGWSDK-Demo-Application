//
//  PaymentApi.swift
//  PGWSDKDemoApplication
//
//  Created by DavidBilly on 1/7/25.
//

import Foundation
import UIKit
import PGW
import PGWHelper
import SwiftUICore

@objc class PaymentApi: NSObject, ObservableObject {

    static let shared = PaymentApi()
    @Published var webviewScreen: (Binding<Bool>, String, String) = (Binding.constant(false), "", "")
    
    //Reference: https://developer.2c2p.com/docs/sdk-api-do-payment
    private static func proceedTransaction(_ request: TransactionResultRequest) {
                 
        PGWSDK.shared.proceedTransaction(transactionResultRequest: request, { (response: TransactionResultResponse) in

            if response.responseCode == APIResponseCode.TransactionAuthenticateRedirect || response.responseCode == APIResponseCode.TransactionAuthenticateFullRedirect {
                         
                let redirectUrl: String = response.data //Open WebView
                handleRedirectUrl(redirectUrl)
            } else if response.responseCode == APIResponseCode.TransactionExternalBrowser {
                 
                handleDeepLinkPayment(response)
            } else if response.responseCode == APIResponseCode.TransactionPaymentSlip {
             
                let paymentSlip: String = response.data //Open payment slip on WebView
                handleRedirectUrl(paymentSlip)
            } else if response.responseCode == APIResponseCode.TransactionExternalApplication {
             
                if response.channelCode == PaymentChannelCode.Channel.ZaloPay {

                    handleZaloPay(response)
                } else {

                    handleDeepLinkPayment(response)
                }
            } else if response.responseCode == APIResponseCode.TransactionQRPayment {
             
                let qrUrl = response.data //Display QR image by using url.
                let responseCode = response.responseCode
                handleRedirectUrl(qrUrl, responseCode)
            } else if response.responseCode == APIResponseCode.TransactionCompleted || response.responseCode == PaymentUIResponseCode.TransactionCompleted {

                //Inquiry payment result by using invoice no.
                InfoApi.transactionStatus(paymentToken)
            } else {

                //Get error response and display error.
                ContentView.showAlertDialog(Constants.apiDoPayment.0, TransactionResultResponse.parse(response))
            }
        }) { (error: NSError) in
            
            //Get error response and display error.
            ContentView.showAlertDialog(Constants.apiDoPayment.0, "Error: \(error.domain)")
        }
    }

    //Reference: https://developer.2c2p.com/docs/sdk-handle-pgw-payment-authentication
    private static func handleRedirectUrl(_ url: String, _ responseCode: String = "") {

        PaymentApi.shared.webviewScreen = (Binding.constant(true), url, responseCode)
    }

    //Reference: https://developer.2c2p.com/docs/sdk-references-handle-deeplink-payment-flow-by-pgw-sdk-helper
    private static func handleDeepLinkPayment(_ response: TransactionResultResponse) {

        //Step 5: Construct deep link payment request.
        let paymentProviderRequest: PaymentProviderRequest = PaymentProviderBuilder()
                                                            .transactionResultResponse(response)
                                                            .build()
                          
        PGWSDKHelper.shared.proceedDeepLinkPayment(paymentProviderRequest: paymentProviderRequest, { (response: DeepLinkPaymentResultResponse) in

            if response.responseCode == DeepLinkPaymentResponseCode.PaymentTransactionStatusInquiry {

                //Inquiry payment result by using payment token.
                InfoApi.transactionStatus(paymentToken)
            }
        }) { (error: NSError) in

            //Get error response and display error.
            ContentView.showAlertDialog(Constants.apiDoPayment.0, "Error: \(error.domain)")
        }
    }

    //Reference: https://developer.2c2p.com/docs/sdk-method-zalopay
    private static func handleZaloPay(_ response: TransactionResultResponse) {

        //Step 5: Construct ZaloPay payment request.
        let paymentProviderRequest: PaymentProviderRequest = PaymentProviderBuilder()
                                                            .transactionResultResponse(response)
                                                            .build()
                          
        PGWSDKHelper.shared.proceedZaloPayPayment(paymentProviderRequest: paymentProviderRequest, { (response: ZaloPayPaymentResultResponse) in

            if response.responseCode == ZaloPayPaymentResponseCode.PaymentSuccess {

                //Inquiry payment result by using payment token.
            } else {

                //Get error response and display error.
            }

            ContentView.showAlertDialog(Constants.apiDoPayment.0, JSONHelper.toJson(response))
        }) { (error: NSError) in

            //Get error response and display error.
            ContentView.showAlertDialog(Constants.apiDoPayment.0, "Error: \(error.domain)")
        }
    }

    //Reference: https://developer.2c2p.com/docs/sdk-api-payment-ui
    @objc static func paymentUI() {

        //Step 1: Generate payment token.
        let paymentToken: String = paymentToken
            
        //Step 2: Construct payment ui request.
        let paymentUIRequest: PaymentUIRequest = PaymentUIBuilder(uiViewController: ContentView.viewController()!).build()
                 
        //Step 3: Construct transaction request.
        let transactionResultRequest: TransactionResultRequest = TransactionResultRequestBuilder(paymentToken: paymentToken)
                                                                 .with(paymentUIRequest)
                                                                 .build()
        
        //Step 4: Execute payment ui request.
        proceedTransaction(transactionResultRequest)
    }

    //Reference: https://developer.2c2p.com/docs/sdk-method-credit-debit-card
    @objc static func globalCreditDebitCard() {
        
        //Step 1: Generate payment token.
        let paymentToken: String = paymentToken
             
        //Step 2: Construct credit card request.
        let paymentCode: PaymentCode = PaymentCode(channelCode: "CC")
          
        let paymentRequest: PaymentRequest = CardPaymentBuilder(paymentCode: paymentCode, "4111111111111111")
                                             .expiryMonth(12)
                                             .expiryYear(2026)
                                             .securityCode("123")
                                             .build()
        
        //Step 3: Construct transaction request.
        let transactionResultRequest: TransactionResultRequest = TransactionResultRequestBuilder(paymentToken: paymentToken)
                                                                 .with(paymentRequest)
                                                                 .build()

        //Step 4: Execute payment request.
        proceedTransaction(transactionResultRequest)
    }

    //Reference: https://developer.2c2p.com/docs/sdk-method-credit-debit-card-local
    @objc static func localCreditDebitCard() {

        //Step 1: Generate payment token.
        let paymentToken: String = paymentToken
            
        //Step 2: Construct local credit card request.
        let paymentCode: PaymentCode = PaymentCode(channelCode: "KBZ")
         
        let paymentRequest: PaymentRequest = CardPaymentBuilder(paymentCode: paymentCode, "9505081000129999")
                                             .expiryMonth(12)
                                             .expiryYear(2026)
                                             .pin("123456")
                                             .build()
                 
        //Step 3: Construct transaction request.
        let transactionResultRequest: TransactionResultRequest = TransactionResultRequestBuilder(paymentToken: paymentToken)
                                                                 .with(paymentRequest)
                                                                 .build()
        
        //Step 4: Execute payment request.
        proceedTransaction(transactionResultRequest)
    }

    //Reference: https://developer.2c2p.com/docs/sdk-customer-tokenization
    @objc static func customerTokenization() {

        //Step 1: Generate payment token.
        let paymentToken: String = paymentToken
            
        //Step 2: Enable Tokenization.
        let customerTokenization: Bool = true //Enable or Disable Tokenization
         
        //Step 3: Construct credit card request.
        let paymentCode: PaymentCode = PaymentCode(channelCode: "CC")
          
        let paymentRequest: PaymentRequest = CardPaymentBuilder(paymentCode: paymentCode, "4111111111111111")
                                             .expiryMonth(12)
                                             .expiryYear(2026)
                                             .securityCode("123")
                                             .tokenize(customerTokenization)
                                             .build()
                  
        //Step 4: Construct transaction request.
        let transactionResultRequest: TransactionResultRequest = TransactionResultRequestBuilder(paymentToken: paymentToken)
                                                                 .with(paymentRequest)
                                                                 .build()

        //Step 5: Execute payment request.
        proceedTransaction(transactionResultRequest)
    }

    //Reference: https://developer.2c2p.com/docs/sdk-customer-tokenization-without-authorization
    //           https://developer.2c2p.com/docs/sdk-e-wallet-tokenization-without-authorization
    @objc static func customerTokenizationWithoutAuthorisation() {

        //Step 1: Generate payment token.
        let paymentToken: String = paymentToken
             
        //Step 2: Construct credit card request.
        let paymentCode: PaymentCode = PaymentCode(channelCode: "CC")
          
        let paymentRequest: PaymentRequest = CardPaymentBuilder(paymentCode: paymentCode, "4111111111111111")
                                             .expiryMonth(12)
                                             .expiryYear(2026)
                                             .securityCode("123")
                                             .build()
                  
        //Step 3: Construct transaction request.
        let transactionResultRequest: TransactionResultRequest = TransactionResultRequestBuilder(paymentToken: paymentToken)
                                                                 .with(paymentRequest)
                                                                 .build()

        //Step 4: Execute payment request.
        proceedTransaction(transactionResultRequest)
    }

    //Reference: https://developer.2c2p.com/docs/sdk-payment-with-customer-token
    @objc static func customerToken() {

        //Step 1: Generate payment token.
        let paymentToken: String = paymentToken
             
        //Step 2: Set customer token.
        let customerToken: String = "20052010380915759367"
          
        //Step 3: Construct credit card request.
        let paymentCode: PaymentCode = PaymentCode(channelCode: "CC")
           
        let paymentRequest: PaymentRequest = CustomerTokenPaymentBuilder(paymentCode: paymentCode, customerToken)
                                             .securityCode("123")
                                             .build()
                   
        //Step 4: Construct transaction request.
        let transactionResultRequest: TransactionResultRequest = TransactionResultRequestBuilder(paymentToken: paymentToken)
                                                                 .with(paymentRequest)
                                                                 .build()
        
        //Step 5: Execute payment request.
        proceedTransaction(transactionResultRequest)
    }

    //Reference: https://developer.2c2p.com/docs/sdk-installment-payment-plan
    @objc static func installmentPaymentPlan() {

        //Step 1: Generate payment token.
        let paymentToken: String = paymentToken
             
        //Step 2: Construct installment payment plan request.
        let paymentCode: PaymentCode = PaymentCode(channelCode: "IPP")
                 
        let paymentRequest: PaymentRequest = CardPaymentBuilder(paymentCode: paymentCode, "4111111111111111")
                                             .expiryMonth(12)
                                             .expiryYear(2026)
                                             .securityCode("123")
                                             .installmentInterestType(InstallmentInterestTypeCode.Merchant)
                                             .installmentPeriod(6)
                                             .build()
         
        //Step 3: Construct transaction request.
        let transactionResultRequest: TransactionResultRequest = TransactionResultRequestBuilder(paymentToken: paymentToken)
                                                                 .with(paymentRequest)
                                                                 .build()
        
        //Step 4: Execute payment request.
        proceedTransaction(transactionResultRequest)
    }

    //Reference: https://developer.2c2p.com/docs/sdk-recurring-payment-plan
    @objc static func recurringPaymentPlan() {

        //Step 1: Generate payment token.
        let paymentToken: String = paymentToken
             
        //Step 2: Construct recurring payment plan request.
        let paymentCode: PaymentCode = PaymentCode(channelCode: "CC")
          
        let paymentRequest: PaymentRequest = CardPaymentBuilder(paymentCode: paymentCode, "4111111111111111")
                                             .expiryMonth(12)
                                             .expiryYear(2026)
                                             .securityCode("123")
                                             .build()
                  
        //Step 3: Construct transaction request.
        let transactionResultRequest: TransactionResultRequest = TransactionResultRequestBuilder(paymentToken: paymentToken)
                                                                 .with(paymentRequest)
                                                                 .build()
        
        //Step 4: Execute payment request.
        proceedTransaction(transactionResultRequest)
    }

    //Reference: https://developer.2c2p.com/docs/sdk-method-third-party-payment
    @objc static func thirdPartyPayment() {

        //Step 1: Generate payment token.
        let paymentToken: String = paymentToken
              
        //Step 2: Construct third party payment request.
        let paymentCode: PaymentCode = PaymentCode(channelCode: "UPOP")
         
        let paymentRequest: PaymentRequest = CardPaymentBuilder(paymentCode: paymentCode)
                                             .name("DavidBilly")
                                             .email("davidbilly@2c2p.com")
                                             .mobileNo("0888888888")
                                             .build()

        //Step 3: Construct transaction request.
        let transactionResultRequest: TransactionResultRequest = TransactionResultRequestBuilder(paymentToken: paymentToken)
                                                                 .with(paymentRequest)
                                                                 .build()
        
        //Step 4: Execute payment request.
        proceedTransaction(transactionResultRequest)
    }

    //Reference: https://developer.2c2p.com/docs/sdk-user-address-for-payment
    @objc static func userAddressForPayment() {

        //Step 1: Generate payment token.
        let paymentToken: String = paymentToken

        //Step 2: Construct customer billing address information.
        let userBillingAddress: UserBillingAddress = UserBillingAddress()
        userBillingAddress.address1 = "128 Beach Road"
        userBillingAddress.address2 = "#21-04"
        userBillingAddress.address3 = "Guoco Midtown"
        userBillingAddress.city = "Singapore"
        userBillingAddress.countryCode = "SG"
        userBillingAddress.postalCode = "189773"
        userBillingAddress.state = "Singapore"

        let userAddress: UserAddress = UserAddressBuilder()
                                       .userBillingAddress(userBillingAddress)
                                       .build()
            
        //Step 3: Construct payment request and add user address into request.
        let paymentCode: PaymentCode = PaymentCode(channelCode: "CC")
         
        let paymentRequest: PaymentRequest = CardPaymentBuilder(paymentCode: paymentCode, "4111111111111111")
                                             .expiryMonth(12)
                                             .expiryYear(2026)
                                             .securityCode("123")
                                             .userAddress(userAddress)
                                             .build()
                 
        //Step 4: Construct transaction request.
        let transactionResultRequest: TransactionResultRequest = TransactionResultRequestBuilder(paymentToken: paymentToken)
                                                                 .with(paymentRequest)
                                                                 .build()

        //Step 5: Execute payment request.
        proceedTransaction(transactionResultRequest)
    }

    //Reference: https://developer.2c2p.com/docs/sdk-online-direct-debit
    @objc static func onlineDirectDebit() {

        //Step 1: Generate payment token.
        let paymentToken: String = paymentToken

        //Step 2: Construct Online Direct Debit Payment request.
        let paymentCode: PaymentCode = PaymentCode(channelCode: "123", "THKTB", "ODD")

        let paymentRequest: PaymentRequest = OnlineDirectDebitBuilder(paymentCode: paymentCode)
                                             .name("DavidBilly")
                                             .email("davidbilly@2c2p.com")
                                             .mobileNo("08888888")
                                             .build()

        //Step 3: Construct transaction request.
        let transactionResultRequest: TransactionResultRequest = TransactionResultRequestBuilder(paymentToken: paymentToken)
                                                                 .with(paymentRequest)
                                                                 .build()

        //Step 4: Execute payment request.
        proceedTransaction(transactionResultRequest)
    }

    //Reference: https://developer.2c2p.com/docs/sdk-deep-link-payment
    @objc static func deepLinkPayment() {
        
        //Step 1: Generate payment token.
        let paymentToken: String = paymentToken
            
        //Step 2: Construct Deep Link payment request.
        let paymentCode: PaymentCode = PaymentCode(channelCode: "123", "THSCB", "DEEPLINK")
         
        let paymentRequest: PaymentRequest = DeepLinkPaymentBuilder(paymentCode: paymentCode)
                                             .name("DavidBilly")
                                             .email("davidbilly@2c2p.com")
                                             .mobileNo("0888888888")
                                             .build()
                 
        //Step 3: Construct transaction request.
        let transactionResultRequest: TransactionResultRequest = TransactionResultRequestBuilder(paymentToken: paymentToken)
                                                                 .with(paymentRequest)
                                                                 .build()

        //Step 4: Execute payment request.
        proceedTransaction(transactionResultRequest)
    }

    //Reference: https://developer.2c2p.com/docs/sdk-method-internet-banking
    @objc static func internetBanking() {
        
        //Step 1: Generate payment token.
        let paymentToken: String = paymentToken
            
        //Step 2: Construct Internet Banking request.
        let paymentCode: PaymentCode = PaymentCode(channelCode: "123", "THUOB", "IBANKING")
         
        let paymentRequest: PaymentRequest = InternetBankingBuilder(paymentCode: paymentCode)
                                             .name("DavidBilly")
                                             .email("davidbilly@2c2p.com")
                                             .mobileNo("0888888888")
                                             .build()
                 
        //Step 3: Construct transaction request.
        let transactionResultRequest: TransactionResultRequest = TransactionResultRequestBuilder(paymentToken: paymentToken)
                                                                 .with(paymentRequest)
                                                                 .build()

        //Step 4: Execute payment request.
        proceedTransaction(transactionResultRequest)
    }

    //Reference: https://developer.2c2p.com/docs/sdk-method-web-payment
    @objc static func webPayment() {
        
        //Step 1: Generate payment token.
        let paymentToken: String = paymentToken
            
        //Step 2: Construct Web Payment request.
        let paymentCode: PaymentCode = PaymentCode(channelCode: "123", "THBBL", "WEBPAY")
         
        let paymentRequest: PaymentRequest = WebPaymentBuilder(paymentCode: paymentCode)
                                             .name("DavidBilly")
                                             .email("davidbilly@2c2p.com")
                                             .mobileNo("0888888888")
                                             .build()
                 
        //Step 3: Construct transaction request.
        let transactionResultRequest: TransactionResultRequest = TransactionResultRequestBuilder(paymentToken: paymentToken)
                                                                 .with(paymentRequest)
                                                                 .build()

        //Step 4: Execute payment request.
        proceedTransaction(transactionResultRequest)
    }

    //Reference: https://developer.2c2p.com/docs/sdk-method-pay-at-counter
    @objc static func payAtCounter() {
        
        //Step 1: Generate payment token.
        let paymentToken: String = paymentToken

        //Step 2: Construct Pay At Counter request.
        let paymentCode: PaymentCode = PaymentCode(channelCode: "123", "BIGC", "OVERTHECOUNTER")
         
        let paymentRequest: PaymentRequest = PayAtCounterBuilder(paymentCode: paymentCode)
                                             .name("DavidBilly")
                                             .email("davidbilly@2c2p.com")
                                             .mobileNo("0888888888")
                                             .build()

        //Step 3: Construct transaction request.
        let transactionResultRequest: TransactionResultRequest = TransactionResultRequestBuilder(paymentToken: paymentToken)
                                                                 .with(paymentRequest)
                                                                 .build()

        //Step 4: Execute payment request.
        proceedTransaction(transactionResultRequest)
    }

    //Reference: https://developer.2c2p.com/docs/sdk-method-self-service-machines
    @objc static func selfServiceMachines() {

        //Step 1: Generate payment token.
        let paymentToken: String = paymentToken
            
        //Step 2: Construct Self Service Machine request.
        let paymentCode: PaymentCode = PaymentCode(channelCode: "123", "THUOB", "ATM")
         
        let paymentRequest: PaymentRequest = SelfServiceMachineBuilder(paymentCode: paymentCode)
                                             .name("DavidBilly")
                                             .email("davidbilly@2c2p.com")
                                             .mobileNo("0888888888")
                                             .build()
                 
        //Step 3: Construct transaction request.
        let transactionResultRequest: TransactionResultRequest = TransactionResultRequestBuilder(paymentToken: paymentToken)
                                                                 .with(paymentRequest)
                                                                 .build()
        
        //Step 4: Execute payment request.
        proceedTransaction(transactionResultRequest)
    }

    //Reference: https://developer.2c2p.com/docs/sdk-method-qr-payment
    @objc static func qrPayment() {

        //Step 1: Generate payment token.
        let paymentToken: String = paymentToken

        //Step 2: Construct QR request.
        let paymentCode: PaymentCode = PaymentCode(channelCode: "PNQR")

        let paymentRequest: PaymentRequest = QRPaymentBuilder(paymentCode: paymentCode)
                                             .type(QRTypeCode.URL)
                                             .name("DavidBilly")
                                             .email("davidbilly@2c2p.com")
                                             .mobileNo("0888888888")
                                             .build()

        //Step 3: Construct transaction request.
        let transactionResultRequest: TransactionResultRequest = TransactionResultRequestBuilder(paymentToken: paymentToken)
                                                                 .with(paymentRequest)
                                                                 .build()

        //Step 4: Execute payment request.
        proceedTransaction(transactionResultRequest)
    }

    //Reference: https://developer.2c2p.com/docs/sdk-method-buy-now-pay-later
    @objc static func buyNowPayLater() {

        //Step 1: Generate payment token.
        let paymentToken: String = paymentToken
            
        //Step 2: Construct buy now pay later request.
        let paymentCode: PaymentCode = PaymentCode(channelCode: "GRABBNPL")
         
        let paymentRequest: PaymentRequest = BuyNowPayLaterPaymentBuilder(paymentCode: paymentCode)
                                             .name("DavidBilly")
                                             .email("davidbilly@2c2p.com")
                                             .build()
         
        //Step 3: Construct transaction request.
        let transactionResultRequest: TransactionResultRequest = TransactionResultRequestBuilder(paymentToken: paymentToken)
                                                                 .with(paymentRequest)
                                                                 .build()

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
    @objc static func digitalPayment() {

        //Step 1: Generate payment token.
        let paymentToken: String = paymentToken
              
        //Step 2: Construct e-wallet request.
        let paymentCode: PaymentCode = PaymentCode(channelCode: "GRAB")
         
        let paymentRequest: PaymentRequest = DigitalPaymentBuilder(paymentCode: paymentCode)
                                             .name("DavidBilly")
                                             .email("davidbilly@2c2p.com")
                                             .mobileNo("0888888888")
                                             .build()
                   
        //Step 3: Construct transaction request.
        let transactionResultRequest: TransactionResultRequest = TransactionResultRequestBuilder(paymentToken: paymentToken)
                                                                 .with(paymentRequest)
                                                                 .build()
        
        //Step 4: Execute payment request.
        proceedTransaction(transactionResultRequest)
    }

    //Reference: https://developer.2c2p.com/docs/sdk-method-line-pay
    @objc static func linePay() {

        //Step 1: Generate payment token.
        let paymentToken: String = paymentToken
              
        //Step 2: Construct e-wallet request.
        let paymentCode: PaymentCode = PaymentCode(channelCode: "LINE")
         
        let paymentRequest: PaymentRequest = DigitalPaymentBuilder(paymentCode: paymentCode)
                                             .name("DavidBilly")
                                             .email("davidbilly@2c2p.com")
                                             .mobileNo("0888888888")
                                             .build()
                   
        //Step 3: Construct transaction request.
        let transactionResultRequest: TransactionResultRequest = TransactionResultRequestBuilder(paymentToken: paymentToken)
                                                                 .with(paymentRequest)
                                                                 .build()

        //Step 4: Execute payment request.
        proceedTransaction(transactionResultRequest)
    }

    //Reference: https://developer.2c2p.com/docs/sdk-method-apple-pay
    @objc static func applePay() {
        
        Task {
            
            //Step 1: Generate payment token.
            let paymentToken: String = paymentToken
            
            let paymentOptionDetailResponse: PaymentOptionDetailResponse? = await withCheckedContinuation { continuation in
                
                //Step 2: Construct payment option details request.
                let paymentOptionDetailRequest: PaymentOptionDetailRequest = PaymentOptionDetailRequest(paymentToken: paymentToken)
                paymentOptionDetailRequest.categoryCode = PaymentChannelCode.Category.DigitalPayment
                paymentOptionDetailRequest.groupCode = PaymentChannelCode.Group.CardWalletPayment
                
                //Step 3: Retrieve payment option details response.
                PGWSDK.shared.paymentOptionDetail(paymentOptionDetailRequest: paymentOptionDetailRequest, { (response: PaymentOptionDetailResponse) in
                    
                    continuation.resume(returning: response)
                }) { (error: NSError) in
                    
                    continuation.resume(returning: nil)
                }
            }

            //Step 2: Retrieve payment provider info from Payment Option Details API.
            let paymentProvider: PaymentProvider? = paymentOptionDetailResponse?.channels.filter({
                $0.context.code.channelCode == "APPLEPAY"
            }).first?.context.info.paymentProvider

            if paymentProvider != nil {
                
                
                //Step 3: Construct apple pay token request.
                let paymentProviderRequest: PaymentProviderRequest = PaymentProviderBuilder()
                                                                     .paymentProvider(paymentProvider!)
                                                                     .build()
                         
                //Verify Apple Pay are support on device (Optional)
                let supportApplePayPaymentResponse: ApplePayPaymentResultResponse? = await withCheckedContinuation { continuation in
                    
                    PGWSDKHelper.shared.supportApplePayPayment(paymentProviderRequest: paymentProviderRequest, { (response: ApplePayPaymentResultResponse) in
                        
                        continuation.resume(returning: response)
                    }) { (error: NSError) in
                     
                        continuation.resume(returning: nil)
                    }
                }

                if supportApplePayPaymentResponse?.responseCode == ApplePayPaymentResponseCode.SupportedDevice {
                    
                    PGWSDKHelper.shared.proceedApplePayPayment(paymentProviderRequest: paymentProviderRequest, { (response: ApplePayPaymentResultResponse) in
                                 
                        if response.responseCode == ApplePayPaymentResponseCode.TokenGeneratedSuccess {
                                     
                            //Step 4: Construct apple pay payment request.
                            let paymentCode: PaymentCode = PaymentCode(channelCode: "APPLEPAY")

                            let paymentRequest: PaymentRequest = DigitalPaymentBuilder(paymentCode: paymentCode)
                                                                .name("DavidBilly")
                                                                .email("davidbilly@2c2p.com")
                                                                .token(response.token)
                                                                .build()
                                     
                            //Step 5: Construct transaction request.
                            let transactionResultRequest: TransactionResultRequest = TransactionResultRequestBuilder(paymentToken: paymentToken)
                                                                                .with(paymentRequest)
                                                                                .build()
                                     
                            //Step 6: Execute payment request.
                            proceedTransaction(transactionResultRequest)
                        } else {

                            //Get error response and display error
                            Task {
                                
                                await MainActor.run {
                                    
                                    ContentView.showAlertDialog(Constants.paymentApplePay.0, JSONHelper.toJson(response))
                                }
                            }
                        }
                    }) { (error: NSError) in
                     
                        //Get error response and display error
                        Task {
                            
                            await MainActor.run {
                                
                                ContentView.showAlertDialog(Constants.paymentApplePay.0, "Error: \(error.domain)")
                            }
                        }
                    }
                } else {
                    
                    await ContentView.showAlertDialog(Constants.paymentApplePay.0, JSONHelper.toJson(supportApplePayPaymentResponse ?? String("{}")))
                }
            } else {
                
                await ContentView.showAlertDialog(Constants.paymentApplePay.0, Constants.errorApplePayNotEnabled)
            }
        }
    }

    //Reference: https://developer.2c2p.com/docs/sdk-card-loyalty-point-payment
    @objc static func cardLoyaltyPointPayment() {
        
        //Step 1: Generate payment token.
        let paymentToken: String = paymentToken
         
        //Step 2: Construct loyalty point payment request.
        let paymentCode: PaymentCode = PaymentCode(channelCode: "CC")
                 
        var loyaltyPoints: [LoyaltyPoint] = [LoyaltyPoint]()
        var rewards: [LoyaltyPointReward] = [LoyaltyPointReward]()
                 
        //Loyalty point reward info can be retrieve from Loyalty Point Info API
        let reward: LoyaltyPointReward = LoyaltyPointReward()
        reward.id = "1792e2b5-8b41-4712-9b44-4c857ce90c3e"
        reward.quantity = 1.00
        rewards.append(reward)
                 
        //Loyalty point info can be retrieve from Loyalty Point Info API
        let loyaltyPoint: LoyaltyPoint = LoyaltyPoint()
        loyaltyPoint.providerId = "DGC"
        loyaltyPoint.redeemAmount = 1.00
        loyaltyPoint.rewards = rewards
        loyaltyPoints.append(loyaltyPoint)
                 
        let paymentRequest: PaymentRequest = LoyaltyPointPaymentBuilder(paymentCode: paymentCode)
                                             .cardNo("4111111111111111")
                                             .expiryMonth(12)
                                             .expiryYear(2026)
                                             .securityCode("123")
                                             .loyaltyPoints(loyaltyPoints)
                                             .build()
            
        //Step 3: Construct transaction request.
        let transactionResultRequest: TransactionResultRequest = TransactionResultRequestBuilder(paymentToken: paymentToken)
                                                                 .with(paymentRequest)
                                                                 .build()
        
        //Step 4: Execute payment request.
        proceedTransaction(transactionResultRequest)
    }

    //Reference: https://developer.2c2p.com/docs/sdk-method-zalopay
    @objc static func zaloPay() {
        
        //Step 1: Generate payment token.
        let paymentToken: String = paymentToken

        //Step 2: Construct e-wallet request.
        let paymentCode: PaymentCode = PaymentCode(channelCode: "ZALOPAY")
         
        let paymentRequest: PaymentRequest = DigitalPaymentBuilder(paymentCode: paymentCode)
                                             .name("DavidBilly")
                                             .email("davidbilly@2c2p.com")
                                             .mobileNo("08888888")
                                             .build()
         
        //Step 3: Construct transaction request.
        let transactionResultRequest: TransactionResultRequest = TransactionResultRequestBuilder(paymentToken: paymentToken)
                                                                 .with(paymentRequest)
                                                                 .build()
        
        //Step 4: Execute payment request.
        proceedTransaction(transactionResultRequest)
    }

    //Reference: https://developer.2c2p.com/docs/sdk-method-triplea
    @objc static func cryptocurrency() {

        //Step 1: Generate payment token.
        let paymentToken: String = paymentToken

        //Step 2: Construct digital currency request.
        let paymentCode: PaymentCode = PaymentCode(channelCode: "TRIPLEA")
         
        let paymentRequest: PaymentRequest = DigitalCurrencyBuilder(paymentCode: paymentCode)
                                             .name("DavidBilly")
                                             .email("davidbilly@2c2p.com")
                                             .mobileNo("0888888888")
                                             .build()

        //Step 3: Construct transaction request.
        let transactionResultRequest: TransactionResultRequest = TransactionResultRequestBuilder(paymentToken: paymentToken)
                                                                 .with(paymentRequest)
                                                                 .build()

        //Step 4: Execute payment request.
        proceedTransaction(transactionResultRequest)
    }

    //Reference: https://developer.2c2p.com/docs/sdk-method-web-payment-card-wpc
    @objc static func webPaymentCard() {
        
        //Step 1: Generate payment token.
        let paymentToken: String = paymentToken
         
        //Step 2: Construct web payment card request.
        let paymentCode: PaymentCode = PaymentCode(channelCode: "123", "VNABB", "WEBPAY")

        let paymentRequest: PaymentRequest = WebPaymentBuilder(paymentCode: paymentCode)
                                             .cardNo("9704160000000018")
                                             .expiryMonth(12)
                                             .expiryYear(2026)
                                             .issuedMonth(1)
                                             .issuedYear(2023)
                                             .securityCode("123")
                                             .name("DavidBilly")
                                             .email("davidbilly@2c2p.com")
                                             .mobileNo("0888888888")
                                             .build()
         
        //Step 3: Construct transaction request.
        let transactionResultRequest: TransactionResultRequest = TransactionResultRequestBuilder(paymentToken: paymentToken)
                                                                 .with(paymentRequest)
                                                                 .build()

        //Step 4: Execute payment request.
        proceedTransaction(transactionResultRequest)
    }
}
