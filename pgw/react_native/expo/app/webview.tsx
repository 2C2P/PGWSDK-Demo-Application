/*
* Created by DavidBilly PK on 20/1/25.
*/

import React, { useEffect } from 'react';
import WebView from 'react-native-webview';
import RTNPGW, {
  APIResponseCode,
  PGWWebViewNavigation
} from '@2c2p/pgw-sdk-react-native';
import * as App from './_layout';
import Constants from './apis/constants';
import * as InfoApi from './apis/infoAPI';
import { useLocalSearchParams, useRouter } from 'expo-router';

export default function WebViewScreen() {

  const router = useRouter();
  const { url, responseCode } = useLocalSearchParams();
  var timer: NodeJS.Timeout;

  // Only for QR payment
  if (responseCode == APIResponseCode.transactionQRPayment) {
    timer = setInterval(() => { transactionStatus(); }, 15000);
  }

  // Do a looping query or long polling to get transaction status until user scan the QR and make payment
  async function transactionStatus() {

    // Step 1: Generate payment token.
    let paymentToken = App.paymentToken;

    // Step 2: Construct transaction status inquiry request.
    let transactionStatusRequest = {
      'paymentToken': paymentToken,
      'additionalInfo': true
    };

    // Step 3: Retrieve transaction status inquiry response.
    await RTNPGW.transactionStatus(JSON.stringify(transactionStatusRequest)).then((response: string) => {

      let transactionStatusResponse = JSON.parse(response);

      if (transactionStatusResponse?.responseCode != APIResponseCode.transactionInProgress) {

        clearInterval(timer);

        App.instance.showDialog(Constants.apiTransactionStatus.title, response);
        router.back();
      } else {

        // Continue do a looping query or long polling to get transaction status until user scan the QR and make payment
      }
    }).catch((error: Error) => {

      clearInterval(timer);

      // Handle exception error
      // Get error response and display error
      App.instance.showDialog(Constants.titlePGWSDKError, 'Error: ' + error);
    });
  }

  useEffect(() => {
    return () => {
      if (timer) clearInterval(timer);
    }
  }, []);

  return (
    <WebView
      source={{ uri: url.toString() }}
      javaScriptEnabled={true}
      domStorageEnabled={true}
      onNavigationStateChange={(event: any) => {

        // Reference : https://developer.2c2p.com/docs/api-sdk-transaction-status-inquiry
        PGWWebViewNavigation.inquiry(event.url ?? '', (paymentToken: string) => {
          if (paymentToken) {
            InfoApi.transactionStatus(paymentToken);
            router.back();
          }
        });
      }}
    />
  );
}