//
//  Constants.swift
//  PGWSDKDemoApplication
//
//  Created by DavidBilly on 1/6/25.
//

struct Constants {
    
    static let apiClientId = ("Client Id", "Retrieve client id")
    static let apiConfiguration = ("SDK Configuration", "Retrieve sdk configuration parameters")
    static let apiPaymentOption = ("Payment Option API", "")
    static let apiPaymentOptionDetail = ("Payment Option Detail API", "")
    static let apiDoPayment = ("Do Payment API", "")
    static let apiCustomerTokenInfo = ("Customer Token Info API", "")
    static let apiExchangeRate = ("Exchange Rate API", "")
    static let apiUserPreference = ("User Preference API", "")
    static let apiTransactionStatus = ("Transaction Status API", "")
    static let apiSystemInitialization = ("System Initialization API", "")
    static let apiPaymentNotification = ("Payment Notification API", "")
    static let apiCancelTransaction = ("Cancel Transaction API", "")
    static let apiLoyaltyPointInfo = ("Loyalty Point Info API", "")
    
    static let paymentGlobalCreditDebitCard = ("Global Credit Card Debit Payment", "")
    static let paymentCustomerTokenization = ("Customer Tokenization", "")
    static let paymentCustomerTokenizationWithoutAuthorisation = ("Customer Tokenization Without Authorisation", "")
    static let paymentCustomerToken = ("Customer Token", "")
    static let paymentInstallmentPaymentPlan = ("Installment Payment Plan", "")
    static let paymentRecurringPaymentPlan = ("Recurring Payment Plan", "")
    static let paymentUserAddressForPayment = ("UserAddress For Payment", "")
    static let paymentOnlineDirectDebit = ("Online Direct Debit", "")
    static let paymentCardLoyaltyPointPayment = ("Card Loyalty Point Payment", "")
    static let paymentDeepLinkPayment = ("Deep Link Payment", "")
    static let paymentInternetBanking = ("Internet Banking", "")
    static let paymentWebPayment = ("Web Payment", "")
    static let paymentQRPayment = ("QR Payment", "")
    static let paymentPayAtCounter = ("Pay At Counter", "")
    static let paymentSelfServiceMachines = ("Self Service Machines", "")
    static let paymentLocalCreditDebitCard = ("Local Credit Debit Card", "")
    static let paymentThirdPartyPayment = ("Third Party Payment", "")
    static let paymentBuyNowPayLater = ("Buy Now Pay Later", "")
    static let paymentDigitalPayment = ("Digital Payment", "For Grab, MoMo, GCash, Touch and go and more...")
    static let paymentLinePay = ("Line Pay", "")
    static let paymentApplePay = ("Apple Pay", "")
    static let paymentZaloPay = ("Zalo Pay", "")
    static let paymentCryptocurrency = ("Cryptocurrency", "For TRIPLE-A and more...")
    static let paymentWebPaymentCard = ("Web Payment Card", "")
    static let paymentUI = ("Payment UI", "Native V4 payment UI")

    static let errorApplePayNotEnabled = "The Apple Pay are not enabled on 2C2P merchant portal."
}
