import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pgw_sdk/core/pgw_sdk_delegate.dart';
import 'package:pgw_sdk/enum/api_response_code.dart';
import 'package:pgw_sdk/core/pgw_webview_navigation_delegate.dart';
import 'package:pgw_sdk_demo_application/apis/info_api.dart';
import 'package:pgw_sdk_demo_application/constants.dart';
import 'package:pgw_sdk_demo_application/scenes/home_screen.dart';
import 'package:pgw_sdk_demo_application/helper.dart';
import 'package:webview_flutter/webview_flutter.dart';

/*
 * Created by DavidBilly PK on 9/1/25.
 */
class WebViewScreen extends StatefulWidget {

  const WebViewScreen({super.key, required this.url, required this.responseCode});

  final String url;
  final String? responseCode;

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {

  late final WebViewController _controller;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    // Important: PGWNavigationDelegate are required for retrieve payment token.
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        PGWNavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            return NavigationDecision.navigate;
          },
          onHttpAuthRequest: (HttpAuthRequest request) { },
          onProgress: (int progress) { },
          onPageStarted: (String url) { },
          onPageFinished: (String url) { },
          onWebResourceError: (WebResourceError error) { },
          onUrlChange: (UrlChange change) { },
          onInquiry: (String paymentToken) {

            // Do transaction status inquiry
            HomeScreen.backPreviousScreen();

            InfoApi.transactionStatus(paymentToken);
          }
        )
      )
      ..loadRequest(
        Uri.parse(widget.url),
      );

    // Only for QR payment
    if (widget.responseCode == APIResponseCode.transactionQRPayment) {

      _timer = Timer.periodic(const Duration(seconds: 15), (Timer t) => _transactionStatus());
    }
  }

  @override
  void dispose() {

    _timer?.cancel();

    super.dispose();
  }

  // Do a looping query or long polling to get transaction status until user scan the QR and make payment
  void _transactionStatus() {

    Map<String, dynamic> request = {
      'paymentToken': HomeScreen.paymentToken,
      'additionalInfo': true
    };

    PGWSDK().transactionStatus(request, (response) {

      if (response['responseCode'] != APIResponseCode.transactionInProgress) {

        _timer?.cancel();

        HomeScreen.backPreviousScreen();

        HomeScreen.showAlertDialog(Constants.apiTransactionStatus.$1, prettyJson(response, indent: 2));
      } else {

        // Continue do a looping query or long polling to get transaction status until user scan the QR and make payment
      }
    }, (error) {

      _timer?.cancel();

      // Handle exception error
      // Get error response and display error
      HomeScreen.showAlertDialog(Constants.titlePGWSDKError, 'Error: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(Constants.titleAppName),
      ),
      body: WebViewWidget(
        controller: _controller,
      ),
    );
  }
}