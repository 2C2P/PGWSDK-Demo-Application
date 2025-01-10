/*
 * Created by DavidBilly PK on 9/1/25.
 */
class Constants {

  static const (String, String) apiClientId = ('Client Id', 'Retrieve client id');
  static const (String, String) apiConfiguration = ('SDK Configuration', 'Retrieve sdk configuration parameters');
  static const (String, String) apiPaymentOption = ('Payment Option API', '');
  static const (String, String) apiPaymentOptionDetail = ('Payment Option Detail API', '');
  static const (String, String) apiDoPayment = ('Do Payment API', '');
  static const (String, String) apiCustomerTokenInfo = ('Customer Token Info API', '');
  static const (String, String) apiExchangeRate = ('Exchange Rate API', '');
  static const (String, String) apiUserPreference = ('User Preference API', '');
  static const (String, String) apiTransactionStatus = ('Transaction Status API', '');
  static const (String, String) apiSystemInitialization = ('System Initialization API', '');
  static const (String, String) apiPaymentNotification = ('Payment Notification API', '');
  static const (String, String) apiCancelTransaction = ('Cancel Transaction API', '');
  static const (String, String) apiLoyaltyPointInfo = ('Loyalty Point Info API', '');

  static const (String, String) paymentGlobalCreditDebitCard = ('Global Credit Card Debit Payment', '');
  static const (String, String) paymentCustomerTokenization = ('Customer Tokenization', '');
  static const (String, String) paymentCustomerTokenizationWithoutAuthorisation = ('Customer Tokenization Without Authorisation', '');
  static const (String, String) paymentCustomerToken = ('Customer Token', '');
  static const (String, String) paymentGlobalInstallmentPaymentPlan = ('Global Installment Payment Plan', '');
  static const (String, String) paymentLocalInstallmentPaymentPlan = ('Local Installment Payment Plan', '');
  static const (String, String) paymentRecurringPaymentPlan = ('Recurring Payment Plan', '');
  static const (String, String) paymentUserAddressForPayment = ('UserAddress For Payment', '');
  static const (String, String) paymentOnlineDirectDebit = ('Online Direct Debit', '');
  static const (String, String) paymentCardLoyaltyPointPayment = ('Card Loyalty Point Payment', '');
  static const (String, String) paymentDeepLinkPayment = ('Deep Link Payment', '');
  static const (String, String) paymentInternetBanking = ('Internet Banking', '');
  static const (String, String) paymentWebPayment = ('Web Payment', '');
  static const (String, String) paymentQRPayment = ('QR Payment', '');
  static const (String, String) paymentPayAtCounter = ('Pay At Counter', '');
  static const (String, String) paymentSelfServiceMachines = ('Self Service Machines', '');
  static const (String, String) paymentLocalCreditDebitCard = ('local Credit Debit Card', '');
  static const (String, String) paymentThirdPartyPayment = ('Third Party Payment', '');
  static const (String, String) paymentBuyNowPayLater = ('Buy Now Pay Later', '');
  static const (String, String) paymentDigitalPayment = ('Digital Payment', 'For Grab, MoMo, GCash, Touch and go and more...');
  static const (String, String) paymentLinePay = ('Line Pay', '');
  static const (String, String) paymentApplePay = ('Apple Pay', '');
  static const (String, String) paymentGooglePay = ('Google Pay', '');
  static const (String, String) paymentZaloPay = ('Zalo Pay', '');
  static const (String, String) paymentCryptocurrency = ('Cryptocurrency', 'For TRIPLE-A and more...');
  static const (String, String) paymentWebPaymentCard = ('Web Payment Card', '');

  static const String titleSubmit = 'Submit';
  static const String titleClose = 'Close';
  static const String titleAppName = '2C2P Merchant Demo Application V4';
  static const String titlePGWSDKError = 'PGW SDK Error';

  static const String errorApplePayNotEnabled = 'The Apple Pay are not enabled on 2C2P merchant portal.';
  static const String errorGooglePayNotEnabled = 'The Google Pay are not enabled on 2C2P merchant portal.';
}