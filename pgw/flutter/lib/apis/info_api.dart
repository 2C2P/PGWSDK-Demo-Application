import 'package:flutter/cupertino.dart';
import 'package:pgw_sdk/enum/api_environment.dart';
import 'package:pgw_sdk/enum/api_response_code.dart';
import 'package:pgw_sdk/enum/payment_channel_code.dart';
import 'package:pgw_sdk/enum/payment_notification_platform_code.dart';
import 'package:pgw_sdk_demo_application/constants.dart';
import 'package:pgw_sdk/core/pgw_sdk_delegate.dart';
import 'package:pgw_sdk_demo_application/helper.dart';
import 'package:pgw_sdk_demo_application/scenes/home_screen.dart';

/*
 * Created by DavidBilly PK on 9/1/25.
 */
class InfoApi {

  // Reference: https://developer.2c2p.com/docs/sdk-initial-sdk
  // Request: https://developer.2c2p.com/docs/sdk-classes-payment-request#init-pgw-sdk
  static Future<void> initialize() async {

    Map<String, dynamic> request = {
      'apiEnvironment': APIEnvironment.sandbox,
      'log': true
    };

    await PGWSDK().initialize(request, (error) {

      // Handle exception error
      // Get error response and display error
      HomeScreen.showAlertDialog(Constants.titlePGWSDKError, 'Error: $error');
    });
  }

  static void clientId() {

    PGWSDK().clientId((response) {

      HomeScreen.showAlertDialog(Constants.apiClientId.$1, response);
    }, (error) {

      // Handle exception error
      // Get error response and display error
      HomeScreen.showAlertDialog(Constants.titlePGWSDKError, 'Error: $error');
    });
  }

  static void configuration() {

    PGWSDK().configuration((response) {

      HomeScreen.showAlertDialog(Constants.apiConfiguration.$1, prettyJson(response, indent: 2));
    }, (error) {

      // Handle exception error
      // Get error response and display error
      HomeScreen.showAlertDialog(Constants.titlePGWSDKError, 'Error: $error');
    });
  }

  // Reference: https://developer.2c2p.com/docs/sdk-api-payment-option
  // Request: https://developer.2c2p.com/docs/sdk-classes-apis-interface#payment-option-request-api
  // Response: https://developer.2c2p.com/docs/sdk-classes-apis-interface#payment-option-response-api
  static void paymentOption() {

    Map<String, dynamic> request = {
      'paymentToken': HomeScreen.paymentToken
    };

    PGWSDK().paymentOption(request, (response) {

      if (response['responseCode'] == APIResponseCode.apiSuccess) {

        response['channels'].forEach((channel) {

          String channelName = channel['name'];
          debugPrint('channel: $channelName');
        });

        Map<String, dynamic> merchantInfo = response['merchantInfo'];
        String merchantName = merchantInfo['name'];
        String merchantId = merchantInfo['id'];

        debugPrint('merchant info >> name: $merchantName, id: $merchantId');
      } else {

        // Get error response and display error
      }

      HomeScreen.showAlertDialog(Constants.apiPaymentOption.$1, prettyJson(response, indent: 2));
    }, (error) {

      // Handle exception error
      // Get error response and display error
      HomeScreen.showAlertDialog(Constants.titlePGWSDKError, 'Error: $error');
    });
  }

  // Reference: https://developer.2c2p.com/docs/sdk-api-payment-option-details
  // Request: https://developer.2c2p.com/docs/sdk-classes-apis-interface#payment-option-detail-request-api
  // Response: https://developer.2c2p.com/docs/sdk-classes-apis-interface#payment-option-detail-response-api
  static void paymentOptionDetail() {

    Map<String, dynamic> request = {
      'paymentToken': HomeScreen.paymentToken,
      'categoryCode': PaymentChannelCode.category.globalCardPayment,
      'groupCode': PaymentChannelCode.group.creditCard
    };

    PGWSDK().paymentOptionDetail(request, (response) {

      if (response['responseCode'] == APIResponseCode.apiSuccess) {

        response['channels'].forEach((channel) {

          String channelName = channel['name'];
          debugPrint('channel: $channelName');

          String validationName = channel['context']['validation']['name'];
          debugPrint('context.validation.name: $validationName');
        });

        List prefixes = response['validation']?['cardNo']?['prefixes'] ?? [];
        for (String prefix in prefixes) {

          debugPrint('validation.cardNo.prefix: $prefix');
        }
      } else {

        // Get error response and display error
      }

      HomeScreen.showAlertDialog(Constants.apiPaymentOptionDetail.$1, prettyJson(response, indent: 2));
    }, (error) {

      // Handle exception error
      // Get error response and display error
      HomeScreen.showAlertDialog(Constants.titlePGWSDKError, 'Error: $error');
    });
  }

  // Reference: https://developer.2c2p.com/docs/sdk-api-customer-tokens-information
  // Request: https://developer.2c2p.com/docs/sdk-classes-apis-interface#customer-token-info-request-api
  // Response: https://developer.2c2p.com/docs/sdk-classes-apis-interface#customer-token-info-response-api
  static void customerTokenInfo() {

    Map<String, dynamic> request = {
      'paymentToken': HomeScreen.paymentToken
    };

    PGWSDK().customerTokenInfo(request, (response) {

      if (response['responseCode'] == APIResponseCode.apiSuccess) {

        List customerTokens = response['customerTokens'];
        debugPrint('customerTokens length: ${customerTokens.length}');
      } else {

        // Get error response and display error
      }

      HomeScreen.showAlertDialog(Constants.apiCustomerTokenInfo.$1, prettyJson(response, indent: 2));
    }, (error) {

      // Handle exception error
      // Get error response and display error
      HomeScreen.showAlertDialog(Constants.titlePGWSDKError, 'Error: $error');
    });
  }

  // Reference: https://developer.2c2p.com/docs/sdk-api-exchange-rate
  // Request: https://developer.2c2p.com/docs/sdk-classes-apis-interface#exchange-rate-request-api
  // Response: https://developer.2c2p.com/docs/sdk-classes-apis-interface#exchange-rate-response-api
  static void exchangeRate() {

    Map<String, dynamic> request = {
      'paymentToken': HomeScreen.paymentToken,
      'bin': '411111'
    };

    PGWSDK().exchangeRate(request, (response) {

      if (response['responseCode'] == APIResponseCode.apiSuccess) {

        List customerTokens = response['fxRates'];
        debugPrint('fx rate length: ${customerTokens.length}');
      } else {

        // Get error response and display error
      }

      HomeScreen.showAlertDialog(Constants.apiExchangeRate.$1, prettyJson(response, indent: 2));
    }, (error) {

      // Handle exception error
      // Get error response and display error
      HomeScreen.showAlertDialog(Constants.titlePGWSDKError, 'Error: $error');
    });
  }

  // Reference: https://developer.2c2p.com/docs/sdk-api-user-preference
  // Request: https://developer.2c2p.com/docs/sdk-classes-apis-interface#user-preference-request-api
  // Response: https://developer.2c2p.com/docs/sdk-classes-apis-interface#user-preference-response-api
  static void userPreference() {

    Map<String, dynamic> request = {
      'paymentToken': HomeScreen.paymentToken
    };

    PGWSDK().userPreference(request, (response) {

      if (response['responseCode'] == APIResponseCode.apiSuccess) {

        Map<String, dynamic> info = response['info'];
        List channels = info['channels'];

        debugPrint('channels length: ${channels.length}');
      } else {

        // Get error response and display error
      }

      HomeScreen.showAlertDialog(Constants.apiUserPreference.$1, prettyJson(response, indent: 2));
    }, (error) {

      // Handle exception error
      // Get error response and display error
      HomeScreen.showAlertDialog(Constants.titlePGWSDKError, 'Error: $error');
    });
  }

  // Reference: https://developer.2c2p.com/docs/api-sdk-transaction-status-inquiry
  // Request: https://developer.2c2p.com/docs/sdk-classes-apis-interface#transaction-status-request-api
  // Response: https://developer.2c2p.com/docs/sdk-classes-apis-interface#transaction-status-response-api
  static void transactionStatus([String? token]) {

    Map<String, dynamic> request = {
      'paymentToken': token ?? HomeScreen.paymentToken,
      'additionalInfo': true
    };

    PGWSDK().transactionStatus(request, (response) {

      if (response['responseCode'] == APIResponseCode.transactionCompleted) {

        Map<String, dynamic> additionalInfo = response['additionalInfo'];

        debugPrint('invoiceNo: ${additionalInfo['transactionInfo']['invoiceNo']}');
      } else {

        // Get error response and display error
      }

      HomeScreen.showAlertDialog(Constants.apiTransactionStatus.$1, prettyJson(response, indent: 2));
    }, (error) {

      // Handle exception error
      // Get error response and display error
      HomeScreen.showAlertDialog(Constants.titlePGWSDKError, 'Error: $error');
    });
  }

  // Reference: https://developer.2c2p.com/docs/sdk-api-pgw-initialization
  // Request: https://developer.2c2p.com/docs/sdk-classes-apis-interface#system-initialization-request-api
  // Response: https://developer.2c2p.com/docs/sdk-classes-apis-interface#system-initialization-response-api
  static void systemInitialization() {

    Map<String, dynamic> request = <String, dynamic>{};

    PGWSDK().systemInitialization(request, (response) {

      if (response['responseCode'] == APIResponseCode.apiSuccess) {

      } else {

        // Get error response and display error
      }

      HomeScreen.showAlertDialog(Constants.apiSystemInitialization.$1, prettyJson(response, indent: 2));
    }, (error) {

      // Handle exception error
      // Get error response and display error
      HomeScreen.showAlertDialog(Constants.titlePGWSDKError, 'Error: $error');
    });
  }

  // Reference: https://developer.2c2p.com/docs/sdk-api-payment-notification
  // Request: https://developer.2c2p.com/docs/sdk-classes-apis-interface#payment-notification-request-api
  // Response: https://developer.2c2p.com/docs/sdk-classes-apis-interface#payment-notification-response-api
  static void paymentNotification() {

    Map<String, dynamic> request = {
      'paymentToken': HomeScreen.paymentToken,
      'platform': PaymentNotificationPlatformCode.facebook,
      'recipientId': '001',
      'recipientName': 'DavidBilly'
    };

    PGWSDK().paymentNotification(request, (response) {

      if (response['responseCode'] == APIResponseCode.apiSuccess) {

      } else {

        // Get error response and display error
      }

      HomeScreen.showAlertDialog(Constants.apiPaymentNotification.$1, prettyJson(response, indent: 2));
    }, (error) {

      // Handle exception error
      // Get error response and display error
      HomeScreen.showAlertDialog(Constants.titlePGWSDKError, 'Error: $error');
    });
  }

  // Reference: https://developer.2c2p.com/docs/sdk-api-cancel-transaction
  // Request: https://developer.2c2p.com/docs/sdk-classes-apis-interface#cancel-transaction-request-api
  // Response: https://developer.2c2p.com/docs/sdk-classes-apis-interface#cancel-transaction-response-api
  static void cancelTransaction() {

    Map<String, dynamic> request = {
      'paymentToken': HomeScreen.paymentToken
    };

    PGWSDK().cancelTransaction(request, (response) {

      if (response['responseCode'] == APIResponseCode.apiSuccess) {

      } else {

        // Get error response and display error
      }

      HomeScreen.showAlertDialog(Constants.apiCancelTransaction.$1, prettyJson(response, indent: 2));
    }, (error) {

      // Handle exception error
      // Get error response and display error
      HomeScreen.showAlertDialog(Constants.titlePGWSDKError, 'Error: $error');
    });
  }

  // Reference: https://developer.2c2p.com/docs/sdk-api-loyalty-point-information
  // Request: https://developer.2c2p.com/docs/sdk-classes-apis-interface#loyalty-point-info-request-api
  // Response: https://developer.2c2p.com/docs/sdk-classes-apis-interface#loyalty-point-info-response-api
  static void loyaltyPointInfo() {

    Map<String, dynamic> request = {
      'paymentToken': HomeScreen.paymentToken,
      'providerId': 'DGC'
    };

    PGWSDK().loyaltyPointInfo(request, (response) {

      if (response['responseCode'] == APIResponseCode.apiSuccess) {

      } else {

        // Get error response and display error
      }

      HomeScreen.showAlertDialog(Constants.apiLoyaltyPointInfo.$1, prettyJson(response, indent: 2));
    }, (error) {

      // Handle exception error
      // Get error response and display error
      HomeScreen.showAlertDialog(Constants.titlePGWSDKError, 'Error: $error');
    });
  }
}