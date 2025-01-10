import 'package:pgw_sdk/enum/api_response_code.dart';
import 'package:pgw_sdk/enum/google_pay_api_environment.dart';
import 'package:pgw_sdk/enum/installment_interest_type_code.dart';
import 'package:pgw_sdk/enum/payment_channel_code.dart';
import 'package:pgw_sdk/enum/qr_type_code.dart';
import 'package:pgw_sdk/enum/apple_pay_payment_response_code.dart';
import 'package:pgw_sdk/enum/google_pay_payment_response_code.dart';
import 'package:pgw_sdk/enum/deep_link_payment_response_code.dart';
import 'package:pgw_sdk/enum/zalo_pay_api_environment.dart';
import 'package:pgw_sdk/enum/zalo_pay_payment_response_code.dart';
import 'package:pgw_sdk_demo_application/apis/info_api.dart';
import 'package:pgw_sdk_demo_application/constants.dart';
import 'package:pgw_sdk_demo_application/helper.dart';
import 'package:pgw_sdk/core/pgw_sdk_delegate.dart';
import 'package:pgw_sdk/core/pgw_sdk_helper_delegate.dart';
import 'package:pgw_sdk_demo_application/scenes/home_screen.dart';

/*
 * Created by DavidBilly PK on 9/1/25.
 */
class PaymentApi {

  // Reference: https://developer.2c2p.com/docs/sdk-classes-payment-info#payment-request
  // request: https://developer.2c2p.com/docs/sdk-classes-apis-interface#do-payment-request-api
  // request.payment.code: https://developer.2c2p.com/docs/sdk-classes-payment-info#payment-code
  // request.payment.data: https://developer.2c2p.com/docs/sdk-classes-payment-info#payment-data
  final paymentRequest = { // https://developer.2c2p.com/docs/sdk-classes-apis-interface#do-payment-request-api
    'paymentToken': String,
    'clientId': String,
    'locale': String,
    'payment': {
      'code': { // https://developer.2c2p.com/docs/sdk-classes-payment-info#payment-code
        'channelCode': String,
        'agentCode': String,
        'agentChannelCode': String
      },
      'data': { // https://developer.2c2p.com/docs/sdk-classes-payment-info#payment-data
        'name': String,
        'email': String,
        'mobileNo': String,
        'customerNote': String,
        'billingAddress1': String,
        'billingAddress2': String,
        'billingAddress3': String,
        'billingCity': String,
        'billingState': String,
        'billingPostalCode': String,
        'billingCountryCode': String,
        'cardNo': String,
        'expiryMonth': int,
        'expiryYear': int,
        'securityCode': String,
        'pin': String,
        'bank': String,
        'country': String,
        'installmentInterestType': String,
        'installmentPeriod': int,
        'installmentPayLaterPeriod': int,
        'accountNo': String,
        'token': String,
        'qrType': String,
        'paymentExpiry': String,
        'tokenize': bool,
        'fxRateId': String,
        'loyaltyPoints': [{
          'providerId': String,
          'accountNo': String,
          'accountAuthData': String,
          'redeemAmount': double,
          'rewards': [{
              'id': String,
              'quantity': int
          }]
        }],
        'issuedMonth': int,
        'issuedYear': int,
      }
    }
  };

  // Reference: https://developer.2c2p.com/docs/response-code-payment-flow
  //            https://developer.2c2p.com/docs/sdk-api-do-payment
  // Response: https://developer.2c2p.com/docs/sdk-classes-apis-interface#do-payment-response-api
  static void proceedTransaction(Map<String, dynamic> request) {

    PGWSDK().proceedTransaction(request, (response) {

      if (response['responseCode'] == APIResponseCode.transactionAuthenticateRedirect || response['responseCode'] == APIResponseCode.transactionAuthenticateFullRedirect) {

        String redirectUrl = response['data']; //Open WebView
        handleRedirectUrl(redirectUrl);
      } else if (response['responseCode'] == APIResponseCode.transactionExternalBrowser) {

        handleDeepLinkPayment(response);
      } else if (response['responseCode'] == APIResponseCode.transactionPaymentSlip) {

        String paymentSlip = response['data']; //Open payment slip on WebView
        handleRedirectUrl(paymentSlip);
      } else if (response['responseCode'] == APIResponseCode.transactionExternalApplication) {

        if (response['channelCode'] == PaymentChannelCode.channel.zaloPay) {

          handleZaloPay(response);
        } else {

          handleDeepLinkPayment(response);
        }
      } else if (response['responseCode'] == APIResponseCode.transactionQRPayment) {

        String qrUrl = response['data']; //Display QR image by using url.
        String responseCode = response['responseCode'];
        handleRedirectUrl(qrUrl, responseCode);
      } else if (response['responseCode'] == APIResponseCode.transactionCompleted) {

        // Inquiry payment result by using payment token.
        InfoApi.transactionStatus(HomeScreen.paymentToken);
      } else {

        // Get error response and display error.
        HomeScreen.showAlertDialog(Constants.apiDoPayment.$1, prettyJson(response, indent: 2));
      }
    }, (error) {

      // Handle exception error
      // Get error response and display error
      HomeScreen.showAlertDialog(Constants.titlePGWSDKError, 'Error: $error');
    });
  }

  // Reference: https://developer.2c2p.com/docs/sdk-handle-pgw-payment-authentication
  static void handleRedirectUrl(String url, [String? responseCode]) {

    HomeScreen.webViewScreen(url, responseCode);
  }

  // Reference: https://developer.2c2p.com/docs/sdk-references-handle-deeplink-payment-flow-by-pgw-sdk-helper
  static void handleDeepLinkPayment(Map<String, dynamic> transactionResultResponse) {

    // Step 5: Construct deep link payment request.
    PGWSDKHelper().proceedDeepLinkPayment(transactionResultResponse, (response) {

      if (response['responseCode'] == DeepLinkPaymentResponseCode.paymentTransactionStatusInquiry) {

        // Inquiry payment result by using payment token.
        InfoApi.transactionStatus(response['paymentToken']);
      } else {

        HomeScreen.showAlertDialog(Constants.paymentDeepLinkPayment.$1, prettyJson(response, indent: 2));
      }
    }, (error) {

      // Handle exception error
      // Get error response and display error
      HomeScreen.showAlertDialog(Constants.titlePGWSDKError, 'Error: $error');
    });
  }

  // Reference: https://developer.2c2p.com/docs/sdk-method-zalopay#6-construct-zalopay-payment-request
  static void handleZaloPay(Map<String, dynamic> transactionResultResponse) {

    PGWSDKHelper().proceedZaloPayPayment(transactionResultResponse, ZaloPayAPIEnvironment.sandbox, (response) {

      if (response['responseCode'] == ZaloPayPaymentResponseCode.paymentSuccess) {

        // Do transaction status inquiry
        InfoApi.transactionStatus(response['paymentToken']);
      } else {

        HomeScreen.showAlertDialog(Constants.paymentZaloPay.$1, prettyJson(response, indent: 2));
      }
    }, (error) {

      // Handle exception error
      // Get error response and display error
      HomeScreen.showAlertDialog(Constants.titlePGWSDKError, 'Error: $error');
    });
  }

  // Reference: https://developer.2c2p.com/docs/sdk-method-credit-debit-card
  static void globalCreditDebitCard() {

    // Step 1: Generate payment token.
    String paymentToken = HomeScreen.paymentToken;

    // Step 2: Construct credit card request.
    Map<String, dynamic> paymentCode = {
      'channelCode': 'CC'
    };

    Map<String, dynamic> paymentRequest = {
      'cardNo': '4111111111111111',
      'expiryMonth': 12,
      'expiryYear': 2026,
      'securityCode': '123'
    };

    // Step 3: Construct transaction request.
    Map<String, dynamic> transactionResultRequest = {
      'paymentToken': paymentToken,
      'payment': {
        'code': {
          ...paymentCode
        },
        'data': {
          ...paymentRequest
        }
      }
    };

    // Step 4: Execute payment request.
    proceedTransaction(transactionResultRequest);
  }

  // Reference: https://developer.2c2p.com/docs/sdk-method-credit-debit-card-local
  static void localCreditDebitCard() {

    // Step 1: Generate payment token.
    String paymentToken = HomeScreen.paymentToken;

    // Step 2: Construct local credit card request.
    Map<String, dynamic> paymentCode = {
      'channelCode': 'KBZ'
    };

    Map<String, dynamic> paymentRequest = {
      'cardNo': '9505081000129999',
      'expiryMonth': 12,
      'expiryYear': 2026,
      'pin': '123456'
    };

    // Step 3: Construct transaction request.
    Map<String, dynamic> transactionResultRequest = {
      'paymentToken': paymentToken,
      'payment': {
        'code': {
          ...paymentCode
        },
        'data': {
          ...paymentRequest
        }
      }
    };

    // Step 4: Execute payment request.
    proceedTransaction(transactionResultRequest);
  }

  // Reference: https://developer.2c2p.com/docs/sdk-customer-tokenization
  static void customerTokenization() {

    // Step 1: Generate payment token.
    String paymentToken = HomeScreen.paymentToken;

    // Step 2: Enable Tokenization.
    bool customerTokenization = true; //Enable or Disable Tokenization

    // Step 3: Construct credit card request.
    Map<String, dynamic> paymentCode = {
      'channelCode': 'CC'
    };

    Map<String, dynamic> paymentRequest = {
      'cardNo': '4111111111111111',
      'expiryMonth': 12,
      'expiryYear': 2026,
      'securityCode': '123',
      'tokenize': customerTokenization
    };

    // Step 4: Construct transaction request.
    Map<String, dynamic> transactionResultRequest = {
      'paymentToken': paymentToken,
      'payment': {
        'code': {
          ...paymentCode
        },
        'data': {
          ...paymentRequest
        }
      }
    };

    // Step 4: Execute payment request.
    proceedTransaction(transactionResultRequest);
  }

  // Reference: https://developer.2c2p.com/docs/sdk-customer-tokenization-without-authorization
  //            https://developer.2c2p.com/docs/sdk-e-wallet-tokenization-without-authorization
  static void customerTokenizationWithoutAuthorisation() {

    // Step 1: Generate payment token.
    String paymentToken = HomeScreen.paymentToken;

    // Step 2: Construct credit card request.
    Map<String, dynamic> paymentCode = {
      'channelCode': 'CC'
    };

    Map<String, dynamic> paymentRequest = {
      'cardNo': '4111111111111111',
      'expiryMonth': 12,
      'expiryYear': 2026,
      'securityCode': '123'
    };

    // Step 3: Construct transaction request.
    Map<String, dynamic> transactionResultRequest = {
      'paymentToken': paymentToken,
      'payment': {
        'code': {
          ...paymentCode
        },
        'data': {
          ...paymentRequest
        }
      }
    };

    // Step 4: Execute payment request.
    proceedTransaction(transactionResultRequest);
  }

  // Reference: https://developer.2c2p.com/docs/sdk-payment-with-customer-token
  static void customerToken() {

    // Step 1: Generate payment token.
    String paymentToken = HomeScreen.paymentToken;

    // Step 2: Set customer token.
    String customerToken = '20052010380915759367';

    // Step 3: Construct credit card request.
    Map<String, dynamic> paymentCode = {
      'channelCode': 'CC'
    };

    Map<String, dynamic> paymentRequest = {
      'token': customerToken,
      'securityCode': '123'
    };

    // Step 4: Construct transaction request.
    Map<String, dynamic> transactionResultRequest = {
      'paymentToken': paymentToken,
      'payment': {
        'code': {
          ...paymentCode
        },
        'data': {
          ...paymentRequest
        }
      }
    };

    // Step 5: Execute payment request.
    proceedTransaction(transactionResultRequest);
  }

  // Reference: https://developer.2c2p.com/docs/sdk-installment-payment-plan
  static void globalInstallmentPaymentPlan() {

    // Step 1: Generate payment token.
    String paymentToken = HomeScreen.paymentToken;

    // Step 2: Construct installment payment plan request.
    Map<String, dynamic> paymentCode = {
      'channelCode': 'IPP'
    };

    Map<String, dynamic> paymentRequest = {
      'cardNo': '4111111111111111',
      'expiryMonth': 12,
      'expiryYear': 2026,
      'securityCode': '123',
      'installmentInterestType': InstallmentInterestTypeCode.merchant,
      'installmentPeriod': 6
    };

    // Step 3: Construct transaction request.
    Map<String, dynamic> transactionResultRequest = {
      'paymentToken': paymentToken,
      'payment': {
        'code': {
          ...paymentCode
        },
        'data': {
          ...paymentRequest
        }
      }
    };

    // Step 4: Execute payment request.
    proceedTransaction(transactionResultRequest);
  }

  // Reference: https://developer.2c2p.com/docs/sdk-installment-payment-plan-local
  static void localInstallmentPaymentPlan() {

    // Step 1: Generate payment token.
    String paymentToken = HomeScreen.paymentToken;

    //Step 2: Construct local installment payment plan request.
    Map<String, dynamic> paymentCode = {
      'channelCode': 'LIPP'
    };

    Map<String, dynamic> paymentRequest = {
      'cardNo': '4111111111111111',
      'expiryMonth': 12,
      'expiryYear': 2026,
      'securityCode': '123',
      'installmentInterestType': InstallmentInterestTypeCode.merchant,
      'installmentPeriod': 6
    };

    // Step 3: Construct transaction request.
    Map<String, dynamic> transactionResultRequest = {
      'paymentToken': paymentToken,
      'payment': {
        'code': {
          ...paymentCode
        },
        'data': {
          ...paymentRequest
        }
      }
    };

    // Step 4: Execute payment request.
    proceedTransaction(transactionResultRequest);
  }

  // Reference: https://developer.2c2p.com/docs/sdk-recurring-payment-plan
  static void recurringPaymentPlan() {

    // Step 1: Generate payment token.
    String paymentToken = HomeScreen.paymentToken;

    // Step 2: Construct recurring payment plan request.
    Map<String, dynamic> paymentCode = {
      'channelCode': 'CC'
    };

    Map<String, dynamic> paymentRequest = {
      'cardNo': '4111111111111111',
      'expiryMonth': 12,
      'expiryYear': 2026,
      'securityCode': '123'
    };

    // Step 3: Construct transaction request.
    Map<String, dynamic> transactionResultRequest = {
      'paymentToken': paymentToken,
      'payment': {
        'code': {
          ...paymentCode
        },
        'data': {
          ...paymentRequest
        }
      }
    };

    // Step 4: Execute payment request.
    proceedTransaction(transactionResultRequest);
  }

  // Reference: https://developer.2c2p.com/docs/sdk-method-third-party-payment
  static void thirdPartyPayment() {

    // Step 1: Generate payment token.
    String paymentToken = HomeScreen.paymentToken;

    // Step 2: Construct third party payment request.
    Map<String, dynamic> paymentCode = {
      'channelCode': 'UPOP'
    };

    Map<String, dynamic> paymentRequest = {
      'name': 'DavidBilly',
      'email': 'davidbilly@2c2p.com',
      'mobileNo': '0888888888'
    };

    // Step 3: Construct transaction request
    Map<String, dynamic> transactionResultRequest = {
      'paymentToken': paymentToken,
      'payment': {
        'code': {
          ...paymentCode
        },
        'data': {
          ...paymentRequest
        }
      }
    };

    // Step 4: Execute payment request.
    proceedTransaction(transactionResultRequest);
  }

  // Reference: https://developer.2c2p.com/docs/sdk-user-address-for-payment
  static void userAddressForPayment() {

    // Step 1: Generate payment token.
    String paymentToken = HomeScreen.paymentToken;

    // Step 2: Construct customer billing address information.
    Map<String, dynamic> userAddress = {
      'billingAddress1': '128 Beach Road',
      'billingAddress2': '#21-04',
      'billingAddress3': 'Guoco Midtown',
      'billingCity': 'Singapore',
      'billingState': 'Singapore',
      'billingPostalCode': '189773',
      'billingCountryCode': 'SG'
    };

    // Step 3: Construct payment request and add user address into request.
    Map<String, dynamic> paymentCode = {
      'channelCode': 'CC'
    };

    Map<String, dynamic> paymentRequest = {
      'cardNo': '4111111111111111',
      'expiryMonth': 12,
      'expiryYear': 2026,
      'securityCode': '123',
      ...userAddress
    };

    // Step 4: Construct transaction request.
    Map<String, dynamic> transactionResultRequest = {
      'paymentToken': paymentToken,
      'payment': {
        'code': {
          ...paymentCode
        },
        'data': {
          ...paymentRequest
        }
      }
    };

    // Step 5: Execute payment request.
    proceedTransaction(transactionResultRequest);
  }

  // Reference: https://developer.2c2p.com/docs/sdk-online-direct-debit
  static void onlineDirectDebit() {

    // Step 1: Generate payment token.
    String paymentToken = HomeScreen.paymentToken;

    // Step 2: Construct Online Direct Debit Payment request.
    Map<String, dynamic> paymentCode = {
      'channelCode': '123',
      'agentCode': 'THKTB',
      'agentChannelCode': 'ODD'
    };

    Map<String, dynamic> paymentRequest = {
      'name': 'DavidBilly',
      'email': 'davidbilly@2c2p.com',
      'mobileNo': '0888888888'
    };

    // Step 3: Construct transaction request.
    Map<String, dynamic> transactionResultRequest = {
      'paymentToken': paymentToken,
      'payment': {
        'code': {
          ...paymentCode
        },
        'data': {
          ...paymentRequest
        }
      }
    };

    // Step 4: Execute payment request.
    proceedTransaction(transactionResultRequest);
  }

  // Reference: https://developer.2c2p.com/docs/sdk-deep-link-payment
  static void deepLinkPayment() {

    // Step 1: Generate payment token.
    String paymentToken = HomeScreen.paymentToken;

    // Step 2: Construct Deep Link payment request.
    Map<String, dynamic> paymentCode = {
      'channelCode': '123',
      'agentCode': 'THSCB',
      'agentChannelCode': 'DEEPLINK'
    };

    Map<String, dynamic> paymentRequest = {
      'name': 'DavidBilly',
      'email': 'davidbilly@2c2p.com',
      'mobileNo': '0888888888'
    };

    // Step 3: Construct transaction request.
    Map<String, dynamic> transactionResultRequest = {
      'paymentToken': paymentToken,
      'payment': {
        'code': {
          ...paymentCode
        },
        'data': {
          ...paymentRequest
        }
      }
    };

    // Step 4: Execute payment request.
    proceedTransaction(transactionResultRequest);
  }

  // Reference: https://developer.2c2p.com/docs/sdk-method-internet-banking
  static void internetBanking() {

    // Step 1: Generate payment token.
    String paymentToken = HomeScreen.paymentToken;

    // Step 2: Construct Internet Banking request.
    Map<String, dynamic> paymentCode = {
      'channelCode': '123',
      'agentCode': 'THUOB',
      'agentChannelCode': 'IBANKING'
    };

    Map<String, dynamic> paymentRequest = {
      'name': 'DavidBilly',
      'email': 'davidbilly@2c2p.com',
      'mobileNo': '0888888888'
    };

    // Step 3: Construct transaction request.
    Map<String, dynamic> transactionResultRequest = {
      'paymentToken': paymentToken,
      'payment': {
        'code': {
          ...paymentCode
        },
        'data': {
          ...paymentRequest
        }
      }
    };

    // Step 4: Execute payment request.
    proceedTransaction(transactionResultRequest);
  }

  // Reference: https://developer.2c2p.com/docs/sdk-method-web-payment
  static void webPayment() {

    // Step 1: Generate payment token.
    String paymentToken = HomeScreen.paymentToken;

    // Step 2: Construct Web Payment request.
    Map<String, dynamic> paymentCode = {
      'channelCode': '123',
      'agentCode': 'THBBL',
      'agentChannelCode': 'WEBPAY'
    };

    Map<String, dynamic> paymentRequest = {
      'name': 'DavidBilly',
      'email': 'davidbilly@2c2p.com',
      'mobileNo': '0888888888'
    };

    // Step 3: Construct transaction request.
    Map<String, dynamic> transactionResultRequest = {
      'paymentToken': paymentToken,
      'payment': {
        'code': {
          ...paymentCode
        },
        'data': {
          ...paymentRequest
        }
      }
    };

    // Step 4: Execute payment request.
    proceedTransaction(transactionResultRequest);
  }

  // Reference: https://developer.2c2p.com/docs/sdk-method-pay-at-counter
  static void payAtCounter() {

    // Step 1: Generate payment token.
    String paymentToken = HomeScreen.paymentToken;

    // Step 2: Construct Pay At Counter request.
    Map<String, dynamic> paymentCode = {
      'channelCode': '123',
      'agentCode': 'BIGC',
      'agentChannelCode': 'OVERTHECOUNTER'
    };

    Map<String, dynamic> paymentRequest = {
      'name': 'DavidBilly',
      'email': 'davidbilly@2c2p.com',
      'mobileNo': '0888888888'
    };

    // Step 3: Construct transaction request.
    Map<String, dynamic> transactionResultRequest = {
      'paymentToken': paymentToken,
      'payment': {
        'code': {
          ...paymentCode
        },
        'data': {
          ...paymentRequest
        }
      }
    };

    // Step 4: Execute payment request.
    proceedTransaction(transactionResultRequest);
  }

  // Reference: https://developer.2c2p.com/docs/sdk-method-self-service-machines
  static void selfServiceMachines() {

    // Step 1: Generate payment token.
    String paymentToken = HomeScreen.paymentToken;

    // Step 2: Construct Self Service Machine request.
    Map<String, dynamic> paymentCode = {
      'channelCode': '123',
      'agentCode': 'THUOB',
      'agentChannelCode': 'ATM'
    };

    Map<String, dynamic> paymentRequest = {
      'name': 'DavidBilly',
      'email': 'davidbilly@2c2p.com',
      'mobileNo': '0888888888'
    };

    // Step 3: Construct transaction request.
    Map<String, dynamic> transactionResultRequest = {
      'paymentToken': paymentToken,
      'payment': {
        'code': {
          ...paymentCode
        },
        'data': {
          ...paymentRequest
        }
      }
    };

    // Step 4: Execute payment request.
    proceedTransaction(transactionResultRequest);
  }

  // Reference: https://developer.2c2p.com/docs/sdk-method-qr-payment
  static void qrPayment() {

    // Step 1: Generate payment token.
    String paymentToken = HomeScreen.paymentToken;

    // Step 2: Construct QR request.
    Map<String, dynamic> paymentCode = {
      'channelCode': 'PNQR'
    };

    Map<String, dynamic> paymentRequest = {
      'qrType': QRTypeCode.url,
      'name': 'DavidBilly',
      'email': 'davidbilly@2c2p.com',
      'mobileNo': '0888888888'
    };

    // Step 3: Construct transaction request.
    Map<String, dynamic> transactionResultRequest = {
      'paymentToken': paymentToken,
      'payment': {
        'code': {
          ...paymentCode
        },
        'data': {
          ...paymentRequest
        }
      }
    };

    // Step 4: Execute payment request.
    proceedTransaction(transactionResultRequest);
  }

  // Reference: https://developer.2c2p.com/docs/sdk-method-buy-now-pay-later
  static void buyNowPayLater() {

    // Step 1: Generate payment token.
    String paymentToken = HomeScreen.paymentToken;

    // Step 2: Construct buy now pay later request.
    Map<String, dynamic> paymentCode = {
      'channelCode': 'GRABBNPL'
    };

    Map<String, dynamic> paymentRequest = {
      'name': 'DavidBilly',
      'email': 'davidbilly@2c2p.com'
    };

    // Step 3: Construct transaction request.
    Map<String, dynamic> transactionResultRequest = {
      'paymentToken': paymentToken,
      'payment': {
        'code': {
          ...paymentCode
        },
        'data': {
          ...paymentRequest
        }
      }
    };

    // Step 4: Execute payment request.
    proceedTransaction(transactionResultRequest);
  }

  // Reference: https://developer.2c2p.com/docs/sdk-method-gcash
  //            https://developer.2c2p.com/docs/sdk-method-grab-pay
  //            https://developer.2c2p.com/docs/sdk-method-touch-n-go
  //            https://developer.2c2p.com/docs/sdk-method-true-money-wallet
  //            https://developer.2c2p.com/docs/sdk-method-wave-pay
  //            https://developer.2c2p.com/docs/sdk-method-ok-dollar-wallet
  //            https://developer.2c2p.com/docs/sdk-method-boost-wallet
  //            https://developer.2c2p.com/docs/sdk-method-master-pass
  //            https://developer.2c2p.com/docs/sdk-method-paypal-wallet
  //            https://developer.2c2p.com/docs/sdk-method-m-pitesan
  //            https://developer.2c2p.com/docs/sdk-method-spa-wallet
  //            https://developer.2c2p.com/docs/sdk-method-kbzpay
  //            https://developer.2c2p.com/docs/sdk-method-cb-pay
  //            https://developer.2c2p.com/docs/sdk-method-ovo
  //            https://developer.2c2p.com/docs/sdk-method-linkaja
  //            https://developer.2c2p.com/docs/sdk-method-alipay
  //            https://developer.2c2p.com/docs/sdk-references-handle-deeplink-payment-flow-by-pgw-sdk-helper
  static void digitalPayment() {

    // Step 1: Generate payment token.
    String paymentToken = HomeScreen.paymentToken;

    // Step 2: Construct e-wallet request.
    Map<String, dynamic> paymentCode = {
      'channelCode': 'GRAB'
    };

    Map<String, dynamic> paymentRequest = {
      'name': 'DavidBilly',
      'email': 'davidbilly@2c2p.com',
      'mobileNo': '0888888888'
    };

    // Step 3: Construct transaction request.
    Map<String, dynamic> transactionResultRequest = {
      'paymentToken': paymentToken,
      'payment': {
        'code': {
          ...paymentCode
        },
        'data': {
          ...paymentRequest
        }
      }
    };

    // Step 4: Execute payment request.
    proceedTransaction(transactionResultRequest);
  }

  // Reference: https://developer.2c2p.com/docs/sdk-references-handle-deeplink-payment-flow-by-pgw-sdk-helper
  static void linePay() {

    // Step 1: Generate payment token.
    String paymentToken = HomeScreen.paymentToken;

    // Step 2: Construct e-wallet request.
    Map<String, dynamic> paymentCode = {
      'channelCode': 'LINE'
    };

    Map<String, dynamic> paymentRequest = {
      'name': 'DavidBilly',
      'email': 'davidbilly@2c2p.com',
      'mobileNo': '0888888888'
    };

    // Step 3: Construct transaction request.
    Map<String, dynamic> transactionResultRequest = {
      'paymentToken': paymentToken,
      'payment': {
        'code': {
          ...paymentCode
        },
        'data': {
          ...paymentRequest
        }
      }
    };

    // Step 4: Execute payment request.
    proceedTransaction(transactionResultRequest);
  }

  // Reference: https://developer.2c2p.com/docs/sdk-method-apple-pay
  //            https://developer.2c2p.com/docs/sdk-references-apple-pay-prerequisite
  // Request: https://developer.2c2p.com/docs/sdk-helper-payment-request
  // Response: https://developer.2c2p.com/docs/sdk-helper-apis-interface#apple-pay-payment-result-response
  static void applePay() async {

    // Step 1: Generate payment token.
    String paymentToken = HomeScreen.paymentToken;

    // Retrieve payment option detail (Mandatory)
    // Step 2: Construct payment option details request.
    Map<String, dynamic> paymentOptionDetailRequest = {
      'paymentToken': paymentToken,
      'categoryCode': PaymentChannelCode.category.digitalPayment,
      'groupCode': PaymentChannelCode.group.cardWalletPayment
    };

    // Step 3: Retrieve payment option details response.
    Map<String, dynamic> paymentOptionDetailResponse = {};
    await PGWSDK().paymentOptionDetail(paymentOptionDetailRequest, (response) {

      paymentOptionDetailResponse = response;
    }, (error) {

      // Handle exception error
      // Get error response and display error
      HomeScreen.showAlertDialog(Constants.titlePGWSDKError, 'Error: $error');
    });

    // Step 2: Retrieve payment provider info from Payment Option Details API.
    Map<String, dynamic>? paymentProvider = paymentOptionDetailResponse['channels']
        .firstWhere((f) => f['context']?['code']?['channelCode'] == 'APPLEPAY', orElse: () => null)?
        ['context']?['info']?['paymentProvider'];

    if (paymentProvider != null) {

      // Retrieve FX (optional)
      Map<String, dynamic> fxRequest = {
        'paymentToken': paymentToken
      };

      Map<String, dynamic> fxResponse = {};
      await PGWSDK().exchangeRate(fxRequest, (response) {

        fxResponse = response;
      }, (error) {

        // Handle exception error
        // Get error response and display error
      });

      List fxRates = fxResponse['fxRates'];
      Map<String, dynamic>? fxRate = fxRates.isNotEmpty ? fxRates.first : null;

      // Verify Apple Pay are support on device (Optional)
      Map<String, dynamic> supportApplePayPaymentResponse = {};
      await PGWSDKHelper().supportApplePayPayment(paymentProvider, (response) {

        supportApplePayPaymentResponse = response;
      }, (error) {

        // Handle exception error
        // Get error response and display error
        HomeScreen.showAlertDialog(Constants.titlePGWSDKError, 'Error: $error');
      });

      if (supportApplePayPaymentResponse['responseCode'] == ApplePayPaymentResponseCode.supportedDevice) {

        // Step 3: Construct apple pay token request.
        PGWSDKHelper().proceedApplePayPayment(paymentProvider, fxRate, (response) { // null or fx

          if (response['responseCode'] == ApplePayPaymentResponseCode.tokenGeneratedSuccess) {

            // Step 4: Construct apple pay payment request.
            Map<String, dynamic> paymentCode = {
              'channelCode': 'APPLEPAY'
            };

            Map<String, dynamic> paymentRequest = {
              'name': 'DavidBilly',
              'email': 'davidbilly@2c2p.com',
              'token': response['token'],
              'fxRateId': fxRate?['id'] ?? ''
            };

            // Step 5: Construct transaction request.
            Map<String, dynamic> transactionResultRequest = {
              'paymentToken': paymentToken,
              'payment': {
                'code': {
                  ...paymentCode
                },
                'data': {
                  ...paymentRequest
                }
              }
            };

            // Step 6: Execute payment request.
            proceedTransaction(transactionResultRequest);
          } else {

            HomeScreen.showAlertDialog(Constants.paymentApplePay.$1, prettyJson(response, indent: 2));
          }
        }, (error) {

          // Handle exception error
          // Get error response and display error
          HomeScreen.showAlertDialog(Constants.titlePGWSDKError, 'Error: $error');
        });
      } else {

        HomeScreen.showAlertDialog(Constants.paymentApplePay.$1, prettyJson(supportApplePayPaymentResponse, indent: 2));
      }
    } else {

      HomeScreen.showAlertDialog(Constants.paymentApplePay.$1, Constants.errorApplePayNotEnabled);
    }
  }

  // Reference: https://developer.2c2p.com/docs/sdk-method-google-pay
  //            https://developer.2c2p.com/docs/sdk-references-google-pay-prerequisite
  static void googlePay() async {

    // Step 1: Generate payment token.
    String paymentToken = HomeScreen.paymentToken;

    // Retrieve payment option detail (Mandatory)
    // Step 2: Construct payment option details request.
    Map<String, dynamic> paymentOptionDetailRequest = {
      'paymentToken': paymentToken,
      'categoryCode': PaymentChannelCode.category.digitalPayment,
      'groupCode': PaymentChannelCode.group.cardWalletPayment
    };

    // Step 3: Retrieve payment option details response.
    Map<String, dynamic> paymentOptionDetailResponse = {};
    await PGWSDK().paymentOptionDetail(paymentOptionDetailRequest, (response) {

      paymentOptionDetailResponse = response;
    }, (error) {

      // Handle exception error
      // Get error response and display error
      HomeScreen.showAlertDialog(Constants.titlePGWSDKError, 'Error: $error');
    });

    // Step 2: Retrieve payment provider info from Payment Option Details API.
    Map<String, dynamic>? paymentProvider = paymentOptionDetailResponse['channels']
        .firstWhere((f) => f['context']?['code']?['channelCode'] == 'GOOGLEPAY', orElse: () => null)?
        ['context']?['info']?['paymentProvider'];

    if (paymentProvider != null) {

      // Retrieve FX (optional)
      Map<String, dynamic> fxRequest = {
        'paymentToken': paymentToken
      };

      Map<String, dynamic> fxResponse = {};
      await PGWSDK().exchangeRate(fxRequest, (response) {

        fxResponse = response;
      }, (error) {

        // Handle exception error
        // Get error response and display error
      });

      List fxRates = fxResponse['fxRates'];
      Map<String, dynamic>? fxRate = fxRates.isNotEmpty ? fxRates.first : null;

      int googleEnvironment = GooglePayAPIEnvironment.test;

      // Verify Google Pay are support on device (Optional)
      Map<String, dynamic> supportGooglePayPaymentResponse = {};
      await PGWSDKHelper().supportGooglePayPayment(paymentProvider, googleEnvironment, (response) {

        supportGooglePayPaymentResponse = response;
      }, (error) {

        // Handle exception error
        // Get error response and display error
        HomeScreen.showAlertDialog(Constants.titlePGWSDKError, 'Error: $error');
      });

      if (supportGooglePayPaymentResponse['responseCode'] == GooglePayPaymentResponseCode.supportedDevice) {

        // Step 3: Construct google pay token request.
        PGWSDKHelper().proceedGooglePayPayment(paymentProvider, fxRate, googleEnvironment, (response) { // null or fx

          if (response['responseCode'] == GooglePayPaymentResponseCode.tokenGeneratedSuccess) {

            // Step 4: Construct google pay payment request.
            Map<String, dynamic> paymentCode = {
              'channelCode': 'GOOGLEPAY'
            };

            Map<String, dynamic> paymentRequest = {
              'name': 'DavidBilly',
              'email': 'davidbilly@2c2p.com',
              'token': response['token'],
              'fxRateId': fxRate?['id'] ?? ''
            };

            // Step 5: Construct transaction request.
            Map<String, dynamic> transactionResultRequest = {
              'paymentToken': paymentToken,
              'payment': {
                'code': {
                  ...paymentCode
                },
                'data': {
                  ...paymentRequest
                }
              }
            };

            // Step 6: Execute payment request.
            proceedTransaction(transactionResultRequest);
          } else {

            // Get error response and display error.
            HomeScreen.showAlertDialog(Constants.paymentGooglePay.$1, prettyJson(response, indent: 2));
          }
        }, (error) {

          // Handle exception error
          // Get error response and display error
          HomeScreen.showAlertDialog(Constants.titlePGWSDKError, 'Error: $error');
        });
      } else {

        HomeScreen.showAlertDialog(Constants.paymentGooglePay.$1, prettyJson(supportGooglePayPaymentResponse, indent: 2));
      }
    } else {

      HomeScreen.showAlertDialog(Constants.paymentGooglePay.$1, Constants.errorGooglePayNotEnabled);
    }
  }

  // Reference: https://developer.2c2p.com/docs/sdk-card-loyalty-point-payment
  static void cardLoyaltyPointPayment() {

    // Step 1: Generate payment token.
    String paymentToken = HomeScreen.paymentToken;

    // Step 2: Construct loyalty point payment request.
    Map<String, dynamic> paymentCode = {
      'channelCode': 'CC'
    };

    List loyaltyPoints = [];
    List rewards = [];

    // Loyalty point reward info can be retrieve from Loyalty Point Info API
    Map<String, dynamic> reward = {
      'id': '1792e2b5-8b41-4712-9b44-4c857ce90c3e',
      'quantity': 1.00
    };
    rewards.add(reward);

    // Loyalty point info can be retrieve from Loyalty Point Info API
    Map<String, dynamic> loyaltyPoint = {
      'providerId': 'DGC',
      'redeemAmount': 1.00,
      'rewards': rewards
    };
    loyaltyPoints.add(loyaltyPoint);

    Map<String, dynamic> paymentRequest = {
      'cardNo': '4111111111111111',
      'expiryMonth': 12,
      'expiryYear': 2026,
      'securityCode': '123',
      'loyaltyPoints': loyaltyPoints
    };

    // Step 3: Construct transaction request.
    Map<String, dynamic> transactionResultRequest = {
      'paymentToken': paymentToken,
      'payment': {
        'code': {
          ...paymentCode
        },
        'data': {
          ...paymentRequest
        }
      }
    };

    // Step 4: Execute payment request.
    proceedTransaction(transactionResultRequest);
  }

  // Reference: https://developer.2c2p.com/docs/sdk-method-zalopay
  //            https://developer.2c2p.com/docs/sdk-references-zalopay-prerequisite
  // Request: https://developer.2c2p.com/docs/sdk-helper-payment-request
  // Response: https://developer.2c2p.com/docs/sdk-helper-apis-interface#zalopay-payment-result-response
  static void zaloPay() {

    // Step 1: Generate payment token.
    String paymentToken = HomeScreen.paymentToken;

    // Step 2: Construct e-wallet request.
    Map<String, dynamic> paymentCode = {
      'channelCode': 'ZALOPAY'
    };

    Map<String, dynamic> paymentRequest = {
      'name': 'DavidBilly',
      'email': 'davidbilly@2c2p.com',
      'mobileNo': '0888888888'
    };

    // Step 3: Construct transaction request.
    Map<String, dynamic> transactionResultRequest = {
      'paymentToken': paymentToken,
      'payment': {
        'code': {
          ...paymentCode
        },
        'data': {
          ...paymentRequest
        }
      }
    };

    // Step 4: Execute payment request.
    proceedTransaction(transactionResultRequest);
  }

  // Reference: https://developer.2c2p.com/docs/sdk-method-triplea
  static void cryptocurrency() {

    // Step 1: Generate payment token.
    String paymentToken = HomeScreen.paymentToken;

    // Step 2: Construct digital currency request.
    Map<String, dynamic> paymentCode = {
      'channelCode': 'TRIPLEA'
    };

    Map<String, dynamic> paymentRequest = {
      'name': 'DavidBilly',
      'email': 'davidbilly@2c2p.com',
      'mobileNo': '0888888888'
    };

    // Step 3: Construct transaction request.
    Map<String, dynamic> transactionResultRequest = {
      'paymentToken': paymentToken,
      'payment': {
        'code': {
          ...paymentCode
        },
        'data': {
          ...paymentRequest
        }
      }
    };

    // Step 4: Execute payment request.
    proceedTransaction(transactionResultRequest);
  }

  // Reference: https://developer.2c2p.com/docs/sdk-method-web-payment-card
  static void webPaymentCard() {

    // Step 1: Generate payment token.
    String paymentToken = HomeScreen.paymentToken;

    // Step 2: Construct web payment card request.
    Map<String, dynamic> paymentCode = {
      'channelCode': '123',
      'agentCode': 'VNABB',
      'agentChannelCode': 'WEBPAY'
    };

    Map<String, dynamic> paymentRequest = {
      'cardNo': '9704160000000018',
      'expiryMonth': 12,
      'expiryYear': 2026,
      'issuedMonth': 1,
      'issuedYear': 2023,
      'securityCode': '123',
      'name': 'DavidBilly',
      'email': 'davidbilly@2c2p.com',
      'mobileNo': '0888888888'
    };

    // Step 3: Construct transaction request.
    Map<String, dynamic> transactionResultRequest = {
      'paymentToken': paymentToken,
      'payment': {
        'code': {
          ...paymentCode
        },
        'data': {
          ...paymentRequest
        }
      }
    };

    // Step 4: Execute payment request.
    proceedTransaction(transactionResultRequest);
  }
}