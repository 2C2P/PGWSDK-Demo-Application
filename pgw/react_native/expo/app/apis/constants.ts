/*
* Created by DavidBilly PK on 17/1/25.
*/

const constants = {
    
    apiClientId: { title: 'Client Id', description: 'Retrieve client id' },
    apiConfiguration: { title: 'SDK Configuration', description: 'Retrieve sdk configuration parameters' },
    apiPaymentOption: { title: 'Payment Option API', description: '' },
    apiPaymentOptionDetail: { title: 'Payment Option Detail API', description: '' },
    apiDoPayment: { title: 'Do Payment API', description: '' },
    apiCustomerTokenInfo: { title: 'Customer Token Info API', description: '' },
    apiExchangeRate: { title: 'Exchange Rate API', description: '' },
    apiUserPreference: { title: 'User Preference API', description: '' },
    apiTransactionStatus: { title: 'Transaction Status API', description: '' },
    apiSystemInitialization: { title: 'System Initialization API', description: '' },
    apiPaymentNotification: { title: 'Payment Notification API', description: '' },
    apiCancelTransaction: { title: 'Cancel Transaction API', description: '' },
    apiLoyaltyPointInfo: { title: 'Loyalty Point Info API', description: '' },

    paymentGlobalCreditDebitCard: { title: 'Global Credit Card Debit Payment', description: '' },
    paymentLocalCreditDebitCard: { title: 'Local Credit Debit Card', description: '' },
    paymentCustomerTokenization: { title: 'Customer Tokenization', description: '' },
    paymentCustomerTokenizationWithoutAuthorisation: { title: 'Customer Tokenization Without Authorisation', description: '' },
    paymentCustomerToken: { title: 'Customer Token', description: '' },
    paymentGlobalInstallmentPaymentPlan: { title: 'Global Installment Payment Plan', description: '' },
    paymentLocalInstallmentPaymentPlan: { title: 'Local Installment Payment Plan', description: '' },
    paymentRecurringPaymentPlan: { title: 'Recurring Payment Plan', description: '' },
    paymentUserAddressForPayment: { title: 'UserAddress For Payment', description: '' },
    paymentOnlineDirectDebit: { title: 'Online Direct Debit', description: '' },
    paymentCardLoyaltyPointPayment: { title: 'Card Loyalty Point Payment', description: '' },
    paymentDeepLinkPayment: { title: 'Deep Link Payment', description: '' },
    paymentInternetBanking: { title: 'Internet Banking', description: '' },
    paymentWebPayment: { title: 'Web Payment', description: '' },
    paymentQRPayment: { title: 'QR Payment', description: '' },
    paymentPayAtCounter: { title: 'Pay At Counter', description: '' },
    paymentSelfServiceMachines: { title: 'Self Service Machines', description: '' },
    paymentThirdPartyPayment: { title: 'Third Party Payment', description: '' },
    paymentBuyNowPayLater: { title: 'Buy Now Pay Later', description: '' },
    paymentDigitalPayment: { title: 'Digital Payment', description: 'For Grab, MoMo, GCash, Touch and go and more...' },
    paymentLinePay: { title: 'Line Pay', description: '' },
    paymentApplePay: { title: 'Apple Pay', description: '' },
    paymentGooglePay: { title: 'Google Pay', description: '' },
    paymentZaloPay: { title: 'Zalo Pay', description: '' },
    paymentCryptocurrency: { title: 'Cryptocurrency', description: 'For TRIPLE-A and more...' },
    paymentWebPaymentCard: { title: 'Web Payment Card', description: '' },
    paymentUI: { title: 'Payment UI', description: 'Native V4 payment UI' },

    titlePaymentToken: 'Payment Token',
    titleSubmit: 'Submit',
    titleClose: 'Close',
    titleOK: 'OK',
    titleAppName: 'PGW SDK Demo Application',
    titlePGWSDKError: 'PGW SDK Error',

    errorApplePayNotEnabled: 'The Apple Pay are not enabled on 2C2P merchant portal.',
    errorGooglePayNotEnabled: 'The Google Pay are not enabled on 2C2P merchant portal.',
} as const;

export default constants;