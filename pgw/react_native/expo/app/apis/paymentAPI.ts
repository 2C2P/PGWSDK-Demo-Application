/*
* Created by DavidBilly PK on 20/1/25.
*/

import RTNPGW, {
    APIResponseCode,
    PaymentChannelCode,
    DeepLinkPaymentResponseCode,
    InstallmentInterestTypeCode,
    QRTypeCode,
    ApplePayPaymentResponseCode,
    GooglePayAPIEnvironment,
    GooglePayPaymentResponseCode,
    ZaloPayPaymentResponseCode,
    ZaloPayAPIEnvironment,
    PaymentUIResponseCode
} from '@2c2p/pgw-sdk-react-native';
import * as InfoApi from './infoAPI';
import * as App from '../_layout';
import Constants from './constants';

export default function empty() { }

// Reference: https://developer.2c2p.com/docs/sdk-classes-payment-info#payment-request
// request: https://developer.2c2p.com/docs/sdk-classes-apis-interface#do-payment-request-api
// request.payment.code: https://developer.2c2p.com/docs/sdk-classes-payment-info#payment-code
// request.payment.data: https://developer.2c2p.com/docs/sdk-classes-payment-info#payment-data
const paymentRequest = { // https://developer.2c2p.com/docs/sdk-classes-apis-interface#do-payment-request-api
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
            'expiryMonth': Number,
            'expiryYear': Number,
            'securityCode': String,
            'pin': String,
            'bank': String,
            'country': String,
            'installmentInterestType': String,
            'installmentPeriod': Number,
            'installmentPayLaterPeriod': Number,
            'accountNo': String,
            'token': String,
            'qrType': String,
            'paymentExpiry': String,
            'tokenize': Boolean,
            'fxRateId': String,
            'loyaltyPoints': [{
                'providerId': String,
                'accountNo': String,
                'accountAuthData': String,
                'redeemAmount': Number,
                'rewards': [{
                    'id': String,
                    'quantity': Number
                }]
            }],
            'issuedMonth': Number,
            'issuedYear': Number,
        }
    }
};

// Reference: https://developer.2c2p.com/docs/response-code-payment-flow
//            https://developer.2c2p.com/docs/sdk-api-do-payment
// Response: https://developer.2c2p.com/docs/sdk-classes-apis-interface#do-payment-response-api
export async function proceedTransaction(request: {}) {

    await RTNPGW.proceedTransaction(JSON.stringify(request)).then((response: string) => {

        let transactionResultResponse = JSON.parse(response);

        if (transactionResultResponse?.responseCode == APIResponseCode.transactionAuthenticateRedirect || transactionResultResponse?.responseCode == APIResponseCode.transactionAuthenticateFullRedirect) {

            let redirectUrl: string = transactionResultResponse?.data; // Open WebView.
            handleRedirectUrl(redirectUrl);
        } else if (transactionResultResponse?.responseCode == APIResponseCode.transactionExternalBrowser) {

            handleDeepLinkPayment(response); // Open external web app.
        } else if (transactionResultResponse?.responseCode == APIResponseCode.transactionPaymentSlip) {

            let paymentSlip: string = transactionResultResponse?.data; // Open payment slip on WebView.
            handleRedirectUrl(paymentSlip);
        } else if (transactionResultResponse?.responseCode == APIResponseCode.transactionExternalApplication) {

            if (transactionResultResponse?.channelCode == PaymentChannelCode.channel.zaloPay) {
                handleZaloPay(response);
            } else {
                handleDeepLinkPayment(response);
            }
        } else if (transactionResultResponse?.responseCode == APIResponseCode.transactionQRPayment) {

            let qrUrl: string = transactionResultResponse?.data; // Display QR image by using url.
            let responseCode: string = transactionResultResponse?.responseCode;
            handleRedirectUrl(qrUrl, responseCode);
        } else if (transactionResultResponse?.responseCode == APIResponseCode.transactionCompleted) {

            // Inquiry payment result by using payment token.
            InfoApi.transactionStatus(App.paymentToken);
        } else {

            // Get error response and display error.
            App.instance.showDialog(Constants.apiDoPayment.title, response);
        }
    }).catch((error: Error) => {

        // Handle exception error
        // Get error response and display error
        App.instance.showDialog(Constants.titlePGWSDKError, 'Error:' + error);
    });
}

// Reference: https://developer.2c2p.com/docs/sdk-handle-pgw-payment-authentication
async function handleRedirectUrl(url: string, responseCode?: string) {

    App.instance.webViewScreen(url, responseCode ?? '');
}

// Reference: https://developer.2c2p.com/docs/sdk-references-handle-deeplink-payment-flow-by-pgw-sdk-helper
async function handleDeepLinkPayment(transactionResultResponse: string) {

    // Step 5: Construct deep link payment request.
    await RTNPGW.proceedDeepLinkPayment(transactionResultResponse).then((response: string) => {

        let deepLinkPaymentResultResponse = JSON.parse(response);

        if (deepLinkPaymentResultResponse?.responseCode == DeepLinkPaymentResponseCode.paymentTransactionStatusInquiry) {

            // Inquiry payment result by using payment token.
            InfoApi.transactionStatus(deepLinkPaymentResultResponse?.paymentToken);
        } else {

            // Get error response and display error
            App.instance.showDialog(Constants.paymentDeepLinkPayment.title, response);
        }
    }).catch((error: Error) => {

        // Handle exception error
        // Get error response and display error
        App.instance.showDialog(Constants.titlePGWSDKError, 'Error:' + error);
    });
}

// Reference: https://developer.2c2p.com/docs/sdk-method-zalopay#6-construct-zalopay-payment-request
async function handleZaloPay(transactionResultResponse: string) {

    await RTNPGW.proceedZaloPayPayment(transactionResultResponse, ZaloPayAPIEnvironment.sandbox).then((response: string) => {

        let zaloPayPaymentResultResponse = JSON.parse(response);

        if (zaloPayPaymentResultResponse?.responseCode == ZaloPayPaymentResponseCode.paymentSuccess) {

            // Inquiry payment result by using payment token.
            InfoApi.transactionStatus(zaloPayPaymentResultResponse?.paymentToken);
        } else {

            // Get error response and display error
            App.instance.showDialog(Constants.paymentZaloPay.title, response);
        }
    }).catch((error: Error) => {

        // Handle exception error
        // Get error response and display error
        App.instance.showDialog(Constants.titlePGWSDKError, 'Error: ' + error);
    });
}

// Reference: https://developer.2c2p.com/docs/sdk-api-payment-ui
export async function paymentUI() {

    // Step 1: Generate payment token.
    let paymentToken = App.paymentToken;

    // Step 2: Construct payment ui request.
    let paymentUIRequest = {};

    // Step 3: Construct transaction request.
    let transactionResultRequest = {
        'paymentToken': paymentToken,
        'payment': {
            'data': {
                ...paymentUIRequest
            }
        }
    };

    // Step 4: Execute payment ui request.
    await RTNPGW.paymentUI(JSON.stringify(transactionResultRequest)).then((response: string) => {

        let transactionResultResponse = JSON.parse(response);

        if (transactionResultResponse?.responseCode == PaymentUIResponseCode.TransactionCompleted) {

            // Inquiry payment result by using payment token.
            InfoApi.transactionStatus(transactionResultResponse?.paymentToken);
        } else {

            // Get error response and display error
            App.instance.showDialog(Constants.paymentUI.title, response);
        }
    }).catch((error: Error) => {

        // Handle exception error
        // Get error response and display error
        App.instance.showDialog(Constants.titlePGWSDKError, 'Error:' + error);
    });
}

// Reference: https://developer.2c2p.com/docs/sdk-method-credit-debit-card
export async function globalCreditDebitCard() {

    // Step 1: Generate payment token.
    let paymentToken = App.paymentToken;

    // Step 2: Construct credit card request.
    let paymentCode = {
        'channelCode': 'CC'
    };

    let paymentRequest = {
        'cardNo': '4111111111111111',
        'expiryMonth': 12,
        'expiryYear': 2026,
        'securityCode': '123'
    };

    // Step 3: Construct transaction request.
    let transactionResultRequest = {
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
export async function localCreditDebitCard() {

    // Step 1: Generate payment token.
    let paymentToken = App.paymentToken;

    // Step 2: Construct local credit card request.
    let paymentCode = {
        'channelCode': 'KBZ'
    };

    let paymentRequest = {
        'cardNo': '9505081000129999',
        'expiryMonth': 12,
        'expiryYear': 2026,
        'pin': '123456'
    };

    // Step 3: Construct transaction request.
    let transactionResultRequest = {
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
export async function customerTokenization() {

    // Step 1: Generate payment token.
    let paymentToken = App.paymentToken;

    // Step 2: Enable Tokenization.
    let customerTokenization = true; //Enable or Disable Tokenization

    // Step 3: Construct credit card request.
    let paymentCode = {
        'channelCode': 'CC'
    };

    let paymentRequest = {
        'cardNo': '4111111111111111',
        'expiryMonth': 12,
        'expiryYear': 2026,
        'securityCode': '123',
        'tokenize': customerTokenization
    };

    // Step 4: Construct transaction request.
    let transactionResultRequest = {
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

// Reference: https://developer.2c2p.com/docs/sdk-customer-tokenization-without-authorization
//            https://developer.2c2p.com/docs/sdk-e-wallet-tokenization-without-authorization
export async function customerTokenizationWithoutAuthorisation() {

    // Step 1: Generate payment token.
    let paymentToken = App.paymentToken;

    // Step 2: Construct credit card request.
    let paymentCode = {
        'channelCode': 'CC'
    };

    let paymentRequest = {
        'cardNo': '4111111111111111',
        'expiryMonth': 12,
        'expiryYear': 2026,
        'securityCode': '123'
    };

    // Step 3: Construct transaction request.
    let transactionResultRequest = {
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
export async function customerToken() {

    // Step 1: Generate payment token.
    let paymentToken = App.paymentToken;

    // Step 2: Set customer token.
    let customerToken = '06032410311207898884';

    // Step 3: Construct credit card request.
    let paymentCode = {
        'channelCode': 'CC'
    };

    let paymentRequest = {
        'token': customerToken,
        'securityCode': '123'
    };

    // Step 4: Construct transaction request.
    let transactionResultRequest = {
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

// https://developer.2c2p.com/docs/sdk-installment-payment-plan
export async function globalInstallmentPaymentPlan() {

    // Step 1: Generate payment token.
    let paymentToken = App.paymentToken;

    // Step 2: Construct installment payment plan request.
    let paymentCode = {
        'channelCode': 'IPP'
    };

    let paymentRequest = {
        'cardNo': '4111111111111111',
        'expiryMonth': 12,
        'expiryYear': 2026,
        'securityCode': '123',
        'installmentInterestType': InstallmentInterestTypeCode.merchant,
        'installmentPeriod': 6
    };

    // Step 3: Construct transaction request.
    let transactionResultRequest = {
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
export async function localInstallmentPaymentPlan() {

    // Step 1: Generate payment token.
    let paymentToken = App.paymentToken;

    // Step 2: Construct installment payment plan request.
    let paymentCode = {
        'channelCode': 'LIPP'
    };

    let paymentRequest = {
        'cardNo': '4111111111111111',
        'expiryMonth': 12,
        'expiryYear': 2026,
        'securityCode': '123',
        'installmentInterestType': InstallmentInterestTypeCode.merchant,
        'installmentPeriod': 6
    };

    // Step 3: Construct transaction request.
    let transactionResultRequest = {
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
export async function recurringPaymentPlan() {

    // Step 1: Generate payment token.
    let paymentToken = App.paymentToken;

    // Step 2: Construct recurring payment plan request.
    let paymentCode = {
        'channelCode': 'CC'
    };

    let paymentRequest = {
        'cardNo': '4111111111111111',
        'expiryMonth': 12,
        'expiryYear': 2026,
        'securityCode': '123'
    };

    // Step 3: Construct transaction request.
    let transactionResultRequest = {
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
export async function thirdPartyPayment() {

    // Step 1: Generate payment token.
    let paymentToken = App.paymentToken;

    // Step 2: Construct third party payment request.
    let paymentCode = {
        'channelCode': 'UPOP'
    };

    let paymentRequest = {
        'name': 'DavidBilly',
        'email': 'davidbilly@2c2p.com',
        'mobileNo': '0888888888'
    };

    // Step 3: Construct transaction request.
    let transactionResultRequest = {
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
export async function userAddressForPayment() {

    // Step 1: Generate payment token.
    let paymentToken = App.paymentToken;

    // Step 2: Construct customer billing address information.
    let userAddress = {
        'billingAddress1': '128 Beach Road',
        'billingAddress2': '#21-04',
        'billingAddress3': 'Guoco Midtown',
        'billingCity': 'Singapore',
        'billingState': 'Singapore',
        'billingPostalCode': '189773',
        'billingCountryCode': 'SG'
    };

    // Step 3: Construct payment request and add user address into request.
    let paymentCode = {
        'channelCode': 'CC'
    };

    let paymentRequest = {
        'cardNo': '4111111111111111',
        'expiryMonth': 12,
        'expiryYear': 2026,
        'securityCode': '123',
        ...userAddress
    };

    // Step 4: Construct transaction request.
    let transactionResultRequest = {
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
export async function onlineDirectDebit() {

    // Step 1: Generate payment token.
    let paymentToken = App.paymentToken;

    // Step 2: Construct Online Direct Debit Payment request.
    let paymentCode = {
        'channelCode': '123',
        'agentCode': 'THKTB',
        'agentChannelCode': 'ODD'
    };

    let paymentRequest = {
        'name': 'DavidBilly',
        'email': 'davidbilly@2c2p.com',
        'mobileNo': '0888888888'
    };

    // Step 3: Construct transaction request.
    let transactionResultRequest = {
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
export async function deepLinkPayment() {

    // Step 1: Generate payment token.
    let paymentToken = App.paymentToken;

    // Step 2: Construct Deep Link payment request.
    let paymentCode = {
        'channelCode': '123',
        'agentCode': 'THSCB',
        'agentChannelCode': 'DEEPLINK'
    };

    let paymentRequest = {
        'name': 'DavidBilly',
        'email': 'davidbilly@2c2p.com',
        'mobileNo': '0888888888'
    };

    // Step 3: Construct transaction request.
    let transactionResultRequest = {
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
export async function internetBanking() {

    // Step 1: Generate payment token.
    let paymentToken = App.paymentToken;

    // Step 2: Construct Internet Banking request.
    let paymentCode = {
        'channelCode': '123',
        'agentCode': 'THUOB',
        'agentChannelCode': 'IBANKING'
    };

    let paymentRequest = {
        'name': 'DavidBilly',
        'email': 'davidbilly@2c2p.com',
        'mobileNo': '0888888888'
    };

    // Step 3: Construct transaction request.
    let transactionResultRequest = {
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
export async function webPayment() {

    // Step 1: Generate payment token.
    let paymentToken = App.paymentToken;

    // Step 2: Construct Web Payment request.
    let paymentCode = {
        'channelCode': '123',
        'agentCode': 'THBBL',
        'agentChannelCode': 'WEBPAY'
    };

    let paymentRequest = {
        'name': 'DavidBilly',
        'email': 'davidbilly@2c2p.com',
        'mobileNo': '0888888888'
    };

    // Step 3: Construct transaction request.
    let transactionResultRequest = {
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
export async function payAtCounter() {

    // Step 1: Generate payment token.
    let paymentToken = App.paymentToken;

    // Step 2: Construct Pay At Counter request.
    let paymentCode = {
        'channelCode': '123',
        'agentCode': 'BIGC',
        'agentChannelCode': 'OVERTHECOUNTER'
    };

    let paymentRequest = {
        'name': 'DavidBilly',
        'email': 'davidbilly@2c2p.com',
        'mobileNo': '0888888888'
    };

    // Step 3: Construct transaction request.
    let transactionResultRequest = {
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
export async function selfServiceMachines() {

    // Step 1: Generate payment token.
    let paymentToken = App.paymentToken;

    // Step 2: Construct Self Service Machine request.
    let paymentCode = {
        'channelCode': '123',
        'agentCode': 'THUOB',
        'agentChannelCode': 'ATM'
    };

    let paymentRequest = {
        'name': 'DavidBilly',
        'email': 'davidbilly@2c2p.com',
        'mobileNo': '0888888888'
    };

    // Step 3: Construct transaction request.
    let transactionResultRequest = {
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
export async function qrPayment() {

    // Step 1: Generate payment token.
    let paymentToken = App.paymentToken;

    // Step 2: Construct QR request.
    let paymentCode = {
        'channelCode': 'PNQR'
    };

    let paymentRequest = {
        'qrType': QRTypeCode.url,
        'name': 'DavidBilly',
        'email': 'davidbilly@2c2p.com',
        'mobileNo': '0888888888'
    };

    // Step 3: Construct transaction request.
    let transactionResultRequest = {
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
export async function buyNowPayLater() {

    // Step 1: Generate payment token.
    let paymentToken = App.paymentToken;

    // Step 2: Construct buy now pay later request.
    let paymentCode = {
        'channelCode': 'GRABBNPL'
    };

    let paymentRequest = {
        'name': 'DavidBilly',
        'email': 'davidbilly@2c2p.com'
    };

    // Step 3: Construct transaction request.
    let transactionResultRequest = {
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
export async function digitalPayment() {

    // Step 1: Generate payment token.
    let paymentToken = App.paymentToken;

    // Step 2: Construct e-wallet request.
    let paymentCode = {
        'channelCode': 'GRAB'
    };

    let paymentRequest = {
        'name': 'DavidBilly',
        'email': 'davidbilly@2c2p.com',
        'mobileNo': '0888888888'
    };

    // Step 3: Construct transaction request.
    let transactionResultRequest = {
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
export async function linePay() {

    // Step 1: Generate payment token.
    let paymentToken = App.paymentToken;

    // Step 2: Construct e-wallet request.
    let paymentCode = {
        'channelCode': 'LINE'
    };

    let paymentRequest = {
        'name': 'DavidBilly',
        'email': 'davidbilly@2c2p.com',
        'mobileNo': '0888888888'
    };

    // Step 3: Construct transaction request.
    let transactionResultRequest = {
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
export async function applePay() {

    // Step 1: Generate payment token.
    let paymentToken = App.paymentToken;

    // Retrieve payment option detail (Mandatory)
    // Step 2.1: Construct payment option details request.
    let paymentOptionDetailRequest = {
        'paymentToken': paymentToken,
        'categoryCode': PaymentChannelCode.category.digitalPayment,
        'groupCode': PaymentChannelCode.group.cardWalletPayment
    };

    // Step 2.2: Retrieve payment option details response.
    let paymentOptionDetailResponse: any = {};
    await RTNPGW.paymentOptionDetail(JSON.stringify(paymentOptionDetailRequest)).then((response: string) => {

        paymentOptionDetailResponse = JSON.parse(response);
    }).catch((error: Error) => {

        // Handle exception error
        // Get error response and display error
        App.instance.showDialog(Constants.titlePGWSDKError, 'Error: ' + error);
    });

    // Step 2.3: Retrieve payment provider info from Payment Option Details API.
    let paymentProvider = paymentOptionDetailResponse?.channels?.find((element: any) => {
        return element?.context?.code?.channelCode == 'APPLEPAY';
    })?.context?.info?.paymentProvider;

    if (paymentProvider) {

        // Retrieve FX (optional)
        let fxRequest = {
            'paymentToken': paymentToken
        };

        let fxResponse: any = {};
        await RTNPGW.exchangeRate(JSON.stringify(fxRequest)).then((response: string) => {

            fxResponse = JSON.parse(response);
        }).catch((error: Error) => {

            // Handle exception error
            // Get error response and display error
            App.instance.showDialog(Constants.titlePGWSDKError, 'Error: ' + error);
        });

        let fxRates = fxResponse?.fxRates ?? [];
        let fxRate = fxRates.length > 0 ? fxRates[0] : null;

        // Verify Apple Pay are support on device (Optional)
        let supportApplePayPaymentResponse: any = {};
        await RTNPGW.supportApplePayPayment(JSON.stringify(paymentProvider)).then((response: string) => {

            supportApplePayPaymentResponse = JSON.parse(response);
        }).catch((error: Error) => {

            // Handle exception error
            // Get error response and display error
            App.instance.showDialog(Constants.titlePGWSDKError, 'Error: ' + error);
        });

        if (supportApplePayPaymentResponse?.responseCode == ApplePayPaymentResponseCode.supportedDevice) {

            // Step 3: Construct apple pay token request.
            await RTNPGW.proceedApplePayPayment(JSON.stringify(paymentProvider), (fxRate) ? JSON.stringify(fxRate) : null).then((response: string) => { // null or fx

                let applePayPaymentResultResponse = JSON.parse(response);

                if (applePayPaymentResultResponse?.responseCode == ApplePayPaymentResponseCode.tokenGeneratedSuccess) {

                    // Step 4: Construct apple pay payment request.
                    let paymentCode = {
                        'channelCode': 'APPLEPAY'
                    };

                    let paymentRequest = {
                        'name': 'DavidBilly',
                        'email': 'davidbilly@2c2p.com',
                        'token': applePayPaymentResultResponse?.token
                    };

                    // Step 5: Construct transaction request.
                    let transactionResultRequest = {
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

                    // Get error response and display error
                    App.instance.showDialog(Constants.paymentApplePay.title, response);
                }
            }).catch((error: Error) => {

                // Handle exception error
                // Get error response and display error
                App.instance.showDialog(Constants.titlePGWSDKError, 'Error: ' + error);
            });
        } else {

            // Get error response and display error
            App.instance.showDialog(Constants.paymentApplePay.title, JSON.stringify(supportApplePayPaymentResponse));
        }
    } else {

        // Get error response and display error
        App.instance.showDialog(Constants.paymentApplePay.title, Constants.errorApplePayNotEnabled);
    }
}

// Reference: https://developer.2c2p.com/docs/sdk-method-google-pay
//            https://developer.2c2p.com/docs/sdk-references-google-pay-prerequisite
export async function googlePay() {

    // Step 1: Generate payment token.
    let paymentToken = App.paymentToken;

    // Retrieve payment option detail (Mandatory)
    // Step 2.1: Construct payment option details request.
    let paymentOptionDetailRequest = {
        'paymentToken': paymentToken,
        'categoryCode': PaymentChannelCode.category.digitalPayment,
        'groupCode': PaymentChannelCode.group.cardWalletPayment
    };

    // Step 2.2: Retrieve payment option details response.
    let paymentOptionDetailResponse: any = {};
    await RTNPGW.paymentOptionDetail(JSON.stringify(paymentOptionDetailRequest)).then((response: string) => {

        paymentOptionDetailResponse = JSON.parse(response);
    }).catch((error: Error) => {

        // Handle exception error
        // Get error response and display error
        App.instance.showDialog(Constants.titlePGWSDKError, 'Error: ' + error);
    });

    // Step 2.3: Retrieve payment provider info from Payment Option Details API.
    let paymentProvider = paymentOptionDetailResponse?.channels?.find((element: any) => {
        return element?.context?.code?.channelCode == 'GOOGLEPAY';
    })?.context?.info?.paymentProvider;

    if (paymentProvider) {

        // Retrieve FX (optional)
        let fxRequest = {
            'paymentToken': paymentToken
        };

        let fxResponse: any = {};
        await RTNPGW.exchangeRate(JSON.stringify(fxRequest)).then((response: string) => {

            fxResponse = JSON.parse(response);
        }).catch((error: Error) => {

            // Handle exception error
            // Get error response and display error
            App.instance.showDialog(Constants.titlePGWSDKError, 'Error: ' + error);
        });

        let fxRates = fxResponse?.fxRates ?? [];
        let fxRate = fxRates.length > 0 ? fxRates[0] : null;

        let googleEnvironment = GooglePayAPIEnvironment.test;

        // Verify Google Pay are support on device (Optional)
        let supportGooglePayPaymentResponse: any = {};
        await RTNPGW.supportGooglePayPayment(JSON.stringify(paymentProvider), googleEnvironment).then((response: string) => {

            supportGooglePayPaymentResponse = JSON.parse(response);
        }).catch((error: Error) => {

            // Handle exception error
            // Get error response and display error
            App.instance.showDialog(Constants.titlePGWSDKError, 'Error: ' + error);
        });

        if (supportGooglePayPaymentResponse?.responseCode == GooglePayPaymentResponseCode.supportedDevice) {

            // Step 3: Construct google pay token request.
            await RTNPGW.proceedGooglePayPayment(JSON.stringify(paymentProvider), (fxRate) ? JSON.stringify(fxRate) : null, googleEnvironment).then((response: string) => { // null or fx

                let googlePayPaymentResultResponse = JSON.parse(response);

                if (googlePayPaymentResultResponse?.responseCode == GooglePayPaymentResponseCode.tokenGeneratedSuccess) {

                    // Step 4: Construct google pay payment request.
                    let paymentCode = {
                        'channelCode': 'GOOGLEPAY'
                    };

                    let paymentRequest = {
                        'name': 'DavidBilly',
                        'email': 'davidbilly@2c2p.com',
                        'token': googlePayPaymentResultResponse?.token,
                        'fxRateId': googlePayPaymentResultResponse?.fxRateId
                    };

                    // Step 5: Construct transaction request.
                    let transactionResultRequest = {
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

                    // Get error response and display error
                    App.instance.showDialog(Constants.paymentGooglePay.title, response);
                }
            }).catch((error: Error) => {

                // Handle exception error
                // Get error response and display error
                App.instance.showDialog(Constants.titlePGWSDKError, 'Error: ' + error);
            });
        } else {

            // Get error response and display error
            App.instance.showDialog(Constants.paymentGooglePay.title, JSON.stringify(supportGooglePayPaymentResponse));
        }
    } else {

        // Get error response and display error
        App.instance.showDialog(Constants.paymentGooglePay.title, Constants.errorGooglePayNotEnabled);
    }
}

// Reference: https://developer.2c2p.com/docs/sdk-card-loyalty-point-payment
export async function cardLoyaltyPointPayment() {

    // Step 1: Generate payment token.
    let paymentToken = App.paymentToken;

    // Step 2: Construct loyalty point payment request.
    let paymentCode = {
        'channelCode': 'CC'
    };

    let loyaltyPoints = [];
    let rewards = [];

    // Loyalty point reward info can be retrieve from Loyalty Point Info API.
    let reward = {
        'id': '1792e2b5-8b41-4712-9b44-4c857ce90c3e',
        'quantity': 1.00
    };
    rewards.push(reward);

    // Loyalty point info can be retrieve from Loyalty Point Info API.
    let loyaltyPoint = {
        'providerId': 'DGC',
        'redeemAmount': 1.00,
        'rewards': rewards
    };
    loyaltyPoints.push(loyaltyPoint);

    let paymentRequest = {
        'cardNo': '4111111111111111',
        'expiryMonth': 12,
        'expiryYear': 2026,
        'securityCode': '123',
        'loyaltyPoints': loyaltyPoints
    };

    // Step 3: Construct transaction request.
    let transactionResultRequest = {
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
export async function zaloPay() {

    // Step 1: Generate payment token.
    let paymentToken = App.paymentToken;

    // Step 2: Construct e-wallet request.
    let paymentCode = {
        'channelCode': 'ZALOPAY'
    };

    let paymentRequest = {
        'name': 'DavidBilly',
        'email': 'davidbilly@2c2p.com',
        'mobileNo': '0888888888'
    };

    // Step 3: Construct transaction request.
    let transactionResultRequest = {
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
export async function cryptocurrency() {

    // Step 1: Generate payment token.
    let paymentToken = App.paymentToken;

    // Step 2: Construct digital currency request.
    let paymentCode = {
        'channelCode': 'TRIPLEA'
    };

    let paymentRequest = {
        'name': 'DavidBilly',
        'email': 'davidbilly@2c2p.com',
        'mobileNo': '0888888888'
    };

    // Step 3: Construct transaction request
    let transactionResultRequest = {
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
export async function webPaymentCard() {

    // Step 1: Generate payment token.
    let paymentToken = App.paymentToken;

    // Step 2: Construct web payment card request.
    let paymentCode = {
        'channelCode': '123',
        'agentCode': 'VNABB',
        'agentChannelCode': 'WEBPAY'
    };

    let paymentRequest = {
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

    // Step 3: Construct transaction request
    let transactionResultRequest = {
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