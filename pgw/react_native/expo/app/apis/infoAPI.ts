/*
* Created by DavidBilly PK on 17/1/25.
*/

import RTNPGW, {
    APIEnvironment,
    APIResponseCode,
    PaymentChannelCode,
    PaymentNotificationPlatformCode
} from '@2c2p/pgw-sdk-react-native';
import Constants from './constants';
import * as App from '../_layout';

export default function empty() { }

// Reference: https://developer.2c2p.com/docs/sdk-initial-sdk
// Request: https://developer.2c2p.com/docs/sdk-classes-payment-request#init-pgw-sdk
export async function initialize() {

    // Step 1: Construct PGW SDK config parameters.
    let pgwsdkParams = {
        'apiEnvironment': APIEnvironment.sandbox,
        'log': true
    };

    // Step 2: initialize PGW SDK.
    await RTNPGW.initialize(JSON.stringify(pgwsdkParams)).then((response: string) => {

    }).catch((error: Error) => {

        // Handle exception error.
        // Get error response and display error.
        App.instance.showDialog(Constants.titlePGWSDKError, 'Error: ' + error);
    });
}

export async function clientId() {

    await RTNPGW.clientId().then((response: string) => {

        App.instance.showDialog(Constants.apiClientId.title, response);
    }).catch((error: Error) => {

        // Handle exception error.
        // Get error response and display error.
        App.instance.showDialog(Constants.titlePGWSDKError, 'Error:' + error);
    });
}

export async function configuration() {

    await RTNPGW.configuration().then((response: string) => {

        App.instance.showDialog(Constants.apiConfiguration.title, response);
    }).catch((error: Error) => {

        // Handle exception error.
        // Get error response and display error.
        App.instance.showDialog(Constants.titlePGWSDKError, 'Error:' + error);
    });
}

// Reference: https://developer.2c2p.com/docs/sdk-api-payment-option
// Request: https://developer.2c2p.com/docs/sdk-classes-apis-interface#payment-option-request-api
// Response: https://developer.2c2p.com/docs/sdk-classes-apis-interface#payment-option-response-api
export async function paymentOption() {

    // Step 1: Generate payment token.
    let paymentToken = App.paymentToken;

    // Step 2: Construct payment option request.
    let paymentOptionRequest = {
        'paymentToken': paymentToken
    };

    // Step 3: Retrieve payment options response.
    await RTNPGW.paymentOption(JSON.stringify(paymentOptionRequest)).then((response: string) => {

        let paymentOptionResponse = JSON.parse(response);

        if (paymentOptionResponse?.responseCode == APIResponseCode.apiSuccess) {

            // Read payment option response.
            paymentOptionResponse?.channels.forEach(function (channel: any) {

                let channelName: string = channel?.name;
                console.log('channel: ' + channelName);
            });

            let merchantInfo = paymentOptionResponse?.merchantInfo;
            let merchantName: string = merchantInfo?.name;
            let merchantId: string = merchantInfo?.id;

            console.log('merchant info >> name: ' + merchantName + ', id: ' + merchantId);
        } else {

            // Get error response and display error.
        }

        App.instance.showDialog(Constants.apiPaymentOption.title, response);
    }).catch((error: Error) => {

        // Handle exception error.
        // Get error response and display error.
        App.instance.showDialog(Constants.titlePGWSDKError, 'Error: ' + error);
    });
}

// Reference: https://developer.2c2p.com/docs/sdk-api-payment-option-details
// Request: https://developer.2c2p.com/docs/sdk-classes-apis-interface#payment-option-detail-request-api
// Response: https://developer.2c2p.com/docs/sdk-classes-apis-interface#payment-option-detail-response-api
export async function paymentOptionDetail() {

    // Step 1: Generate payment token.
    let paymentToken = App.paymentToken;

    // Step 2: Construct payment option details request.
    let paymentOptionDetailRequest = {
        'paymentToken': paymentToken,
        'categoryCode': PaymentChannelCode.category.globalCardPayment,
        'groupCode': PaymentChannelCode.group.creditCard
    };

    // Step 3: Retrieve payment option details response.
    await RTNPGW.paymentOptionDetail(JSON.stringify(paymentOptionDetailRequest)).then((response: string) => {

        let paymentOptionDetailResponse = JSON.parse(response);

        if (paymentOptionDetailResponse?.responseCode == APIResponseCode.apiSuccess) {

            // Read Payment option details response.
            paymentOptionDetailResponse?.channels.forEach(function (channel: any) {

                let channelName: string = channel?.name;
                console.log('channel: ' + channelName);

                let validationName: string = channel?.context?.validation?.name ?? '';
                console.log('context.validation.name: ' + validationName);
            });

            let prefixes: [] = paymentOptionDetailResponse?.validation?.cardNo?.prefixes ?? [];
            for (let prefix in prefixes) {

                console.log('validation.cardNo.prefix: ' + prefixes[prefix]);
            }
        } else {

            // Get error response and display error.
        }

        App.instance.showDialog(Constants.apiPaymentOptionDetail.title, response);
    }).catch((error: Error) => {

        // Handle exception error.
        // Get error response and display error.
        App.instance.showDialog(Constants.titlePGWSDKError, 'Error: ' + error);
    });
}

// Reference: https://developer.2c2p.com/docs/sdk-api-customer-tokens-information
// Request: https://developer.2c2p.com/docs/sdk-classes-apis-interface#customer-token-info-request-api
// Response: https://developer.2c2p.com/docs/sdk-classes-apis-interface#customer-token-info-response-api
export async function customerTokenInfo() {

    // Step 1: Generate payment token.
    let paymentToken = App.paymentToken;

    // Step 2: Construct customer token info request.
    let customerTokenInfoRequest = {
        'paymentToken': paymentToken
    };

    // Step 3: Retrieve customer token info response.
    await RTNPGW.customerTokenInfo(JSON.stringify(customerTokenInfoRequest)).then((response: string) => {

        let customerTokenInfoResponse = JSON.parse(response);

        if (customerTokenInfoResponse?.responseCode == APIResponseCode.apiSuccess) {

            // Read customer token info response.
            let customerTokens: [] = customerTokenInfoResponse?.customerTokens;
            console.log('customerTokens length: ' + customerTokens.length);
        } else {

            // Get error response and display error.
        }

        App.instance.showDialog(Constants.apiCustomerTokenInfo.title, response);
    }).catch((error: Error) => {

        // Handle exception error.
        // Get error response and display error.
        App.instance.showDialog(Constants.titlePGWSDKError, 'Error: ' + error);
    });
}

// Reference: https://developer.2c2p.com/docs/sdk-api-exchange-rate
// Request: https://developer.2c2p.com/docs/sdk-classes-apis-interface#exchange-rate-request-api
// Response: https://developer.2c2p.com/docs/sdk-classes-apis-interface#exchange-rate-response-api
export async function exchangeRate() {

    // Step 1: Generate payment token.
    let paymentToken = App.paymentToken;

    // Step 2: Construct exchange rate info request.
    let exchangeRateRequest = {
        'paymentToken': paymentToken,
        'bin': '411111'
    };

    // Step 3: Retrieve exchange rate response.
    await RTNPGW.exchangeRate(JSON.stringify(exchangeRateRequest)).then((response: string) => {

        let exchangeRateResponse = JSON.parse(response);

        if (exchangeRateResponse?.responseCode == APIResponseCode.apiSuccess) {

            // Read exchange rate response.
            let customerTokens: [] = exchangeRateResponse?.fxRates ?? [];
            console.log('fx rate length: ' + customerTokens.length);
        } else {

            // Get error response and display error.
        }

        App.instance.showDialog(Constants.apiExchangeRate.title, response);
    }).catch((error: Error) => {

        // Handle exception error.
        // Get error response and display error.
        App.instance.showDialog(Constants.titlePGWSDKError, 'Error: ' + error);
    });
}

// Reference: https://developer.2c2p.com/docs/sdk-api-user-preference
// Request: https://developer.2c2p.com/docs/sdk-classes-apis-interface#user-preference-request-api
// Response: https://developer.2c2p.com/docs/sdk-classes-apis-interface#user-preference-response-api
export async function userPreference() {

    // Step 1: Generate payment token.
    let paymentToken = App.paymentToken;

    // Step 2: Construct user preference request.
    let userPreferenceRequest = {
        'paymentToken': paymentToken
    };

    // Step 3: Retrieve user preference response.
    await RTNPGW.userPreference(JSON.stringify(userPreferenceRequest)).then((response: string) => {

        let userPreferenceResponse = JSON.parse(response);

        if (userPreferenceResponse?.responseCode == APIResponseCode.apiSuccess) {

            // Read user preference response.
            let info = userPreferenceResponse?.info;
            let channels: [] = info?.channels ?? [];

            console.log('channels length: ' + channels.length);
        } else {

            // Get error response and display error.
        }

        App.instance.showDialog(Constants.apiUserPreference.title, response);
    }).catch((error: Error) => {

        // Handle exception error.
        // Get error response and display error.
        App.instance.showDialog(Constants.titlePGWSDKError, 'Error: ' + error);
    });
}

// Reference: https://developer.2c2p.com/docs/api-sdk-transaction-status-inquiry
// Request: https://developer.2c2p.com/docs/sdk-classes-apis-interface#transaction-status-request-api
// Response: https://developer.2c2p.com/docs/sdk-classes-apis-interface#transaction-status-response-api
export async function transactionStatus(token?: string) {

    // Step 1: Generate payment token.
    let paymentToken = token ?? App.paymentToken;

    // Step 2: Construct transaction status inquiry request.
    let transactionStatusRequest = {
        'paymentToken': paymentToken,
        'additionalInfo': true
    };

    // Step 3: Retrieve transaction status inquiry response.
    await RTNPGW.transactionStatus(JSON.stringify(transactionStatusRequest)).then((response: string) => {

        let transactionStatusResponse = JSON.parse(response);

        if (transactionStatusResponse?.responseCode == APIResponseCode.transactionCompleted) {

            // Read transaction status inquiry response.
            let additionalInfo = transactionStatusResponse?.additionalInfo;
            let invoiceNo: string = additionalInfo?.transactionInfo?.invoiceNo ?? '';

            console.log('invoiceNo: ' + invoiceNo);
        } else {

            // Get error response and display error.
        }

        App.instance.showDialog(Constants.apiTransactionStatus.title, response);
    }).catch((error: Error) => {

        // Handle exception error.
        // Get error response and display error.
        App.instance.showDialog(Constants.titlePGWSDKError, 'Error: ' + error);
    });
}

// Reference: https://developer.2c2p.com/docs/sdk-api-pgw-initialization
// Request: https://developer.2c2p.com/docs/sdk-classes-apis-interface#system-initialization-request-api
// Response: https://developer.2c2p.com/docs/sdk-classes-apis-interface#system-initialization-response-api
export async function systemInitialization() {

    // Step 1: Construct system initialization request.
    let systemInitializationRequest = {};

    // Step 2: Retrieve system initialization response.
    await RTNPGW.systemInitialization(JSON.stringify(systemInitializationRequest)).then((response: string) => {

        let systemInitializationResponse = JSON.parse(response);

        if (systemInitializationResponse?.responseCode == APIResponseCode.apiSuccess) {

            // Read system initialization response.
        } else {

            // Get error response and display error.
        }

        App.instance.showDialog(Constants.apiSystemInitialization.title, response);
    }).catch((error: Error) => {

        // Handle exception error.
        // Get error response and display error.
        App.instance.showDialog(Constants.titlePGWSDKError, 'Error: ' + error);
    });
}

// Reference: https://developer.2c2p.com/docs/sdk-api-payment-notification
// Request: https://developer.2c2p.com/docs/sdk-classes-apis-interface#payment-notification-request-api
// Response: https://developer.2c2p.com/docs/sdk-classes-apis-interface#payment-notification-response-api
export async function paymentNotification() {

    // Step 1: Generate payment token.
    let paymentToken = App.paymentToken;

    // Step 2: Construct payment notification request.
    let paymentNotificationRequest = {
        'paymentToken': paymentToken,
        'platform': PaymentNotificationPlatformCode.email,
        'recipientId': 'davidbilly@2c2p.com',
        'recipientName': 'DavidBilly'
    };

    // Step 3: Retrieve payment notification response.
    await RTNPGW.paymentNotification(JSON.stringify(paymentNotificationRequest)).then((response: string) => {

        let paymentNotificationResponse = JSON.parse(response);

        if (paymentNotificationResponse?.responseCode == APIResponseCode.apiSuccess) {

            // Read payment notification response.
        } else {

            // Get error response and display error.
        }

        App.instance.showDialog(Constants.apiPaymentNotification.title, response);
    }).catch((error: Error) => {

        // Handle exception error.
        // Get error response and display error.
        App.instance.showDialog(Constants.titlePGWSDKError, 'Error: ' + error);
    });
}

// Reference: https://developer.2c2p.com/docs/sdk-api-cancel-transaction
// Request: https://developer.2c2p.com/docs/sdk-classes-apis-interface#cancel-transaction-request-api
// Response: https://developer.2c2p.com/docs/sdk-classes-apis-interface#cancel-transaction-response-api
export async function cancelTransaction() {

    // Step 1: Generate payment token.
    let paymentToken = App.paymentToken;

    // Step 2: Construct cancel transaction request.
    let cancelTransactionRequest = {
        'paymentToken': paymentToken
    };

    // Step 3: Retrieve cancel transaction response.
    await RTNPGW.cancelTransaction(JSON.stringify(cancelTransactionRequest)).then((response: string) => {

        let cancelTransactionResponse = JSON.parse(response);

        if (cancelTransactionResponse?.responseCode == APIResponseCode.apiSuccess) {

            // Read cancel transaction response.
        } else {

            // Get error response and display error.
        }

        App.instance.showDialog(Constants.apiCancelTransaction.title, response);
    }).catch((error: Error) => {

        // Handle exception error.
        // Get error response and display error.
        App.instance.showDialog(Constants.titlePGWSDKError, 'Error: ' + error);
    });
}

// Reference: https://developer.2c2p.com/docs/sdk-api-loyalty-point-information
// Request: https://developer.2c2p.com/docs/sdk-classes-apis-interface#loyalty-point-info-request-api
// Response: https://developer.2c2p.com/docs/sdk-classes-apis-interface#loyalty-point-info-response-api
export async function loyaltyPointInfo() {

    // Step 1: Generate payment token.
    let paymentToken = App.paymentToken;

    // Step 2: Construct loyalty point info request.
    let loyaltyPointInfoRequest = {
        'paymentToken': paymentToken,
        'providerId': 'DGC'
    };

    // Step 3: Retrieve loyalty point info response.
    await RTNPGW.loyaltyPointInfo(JSON.stringify(loyaltyPointInfoRequest)).then((response: string) => {

        let loyaltyPointInfoResponse = JSON.parse(response);

        if (loyaltyPointInfoResponse?.responseCode == APIResponseCode.apiSuccess) {

            // Read loyalty point info response.
        } else {

            // Get error response and display error.
        }

        App.instance.showDialog(Constants.apiLoyaltyPointInfo.title, response);
    }).catch((error: Error) => {

        // Handle exception error.
        // Get error response and display error.
        App.instance.showDialog(Constants.titlePGWSDKError, 'Error: ' + error);
    });
}