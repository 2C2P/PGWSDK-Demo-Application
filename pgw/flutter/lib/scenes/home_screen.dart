import 'package:flutter/material.dart';
import 'package:pgw_sdk_demo_application/apis/info_api.dart';
import 'package:pgw_sdk_demo_application/apis/payment_api.dart';
import 'package:pgw_sdk_demo_application/constants.dart';
import 'package:pgw_sdk_demo_application/main.dart';
import 'package:pgw_sdk_demo_application/scenes/webview_screen.dart';

/*
 * Created by DavidBilly PK on 9/1/25.
 */
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Reference: https://developer.2c2p.com/docs/api-payment-token
  static String paymentToken = 'kSAops9Zwhos8hSTSeLTUSbU6jyYcrOBqYq7NpL+uXqXmD/aflU/9Ee9705E9Z5KG5PJ7RvzXqzogasA1zSFTISLprOCzt2Il1RMIjbh8dalYlpDOdzrDcxQ8bdywWg7';

  final List _infoApis = const [
    (Constants.apiClientId, InfoApi.clientId),
    (Constants.apiConfiguration, InfoApi.configuration),
    (Constants.apiPaymentOption, InfoApi.paymentOption),
    (Constants.apiPaymentOptionDetail, InfoApi.paymentOptionDetail),
    (Constants.apiCustomerTokenInfo, InfoApi.customerTokenInfo),
    (Constants.apiExchangeRate, InfoApi.exchangeRate),
    (Constants.apiUserPreference, InfoApi.userPreference),
    (Constants.apiTransactionStatus, InfoApi.transactionStatus),
    (Constants.apiSystemInitialization, InfoApi.systemInitialization),
    (Constants.apiPaymentNotification, InfoApi.paymentNotification),
    (Constants.apiCancelTransaction, InfoApi.cancelTransaction),
    (Constants.apiLoyaltyPointInfo, InfoApi.loyaltyPointInfo)
  ];

  final List _paymentApis = const [
    (Constants.paymentGlobalCreditDebitCard, PaymentApi.globalCreditDebitCard),
    (Constants.paymentLocalCreditDebitCard, PaymentApi.localCreditDebitCard),
    (Constants.paymentCustomerTokenization, PaymentApi.customerTokenization),
    (Constants.paymentCustomerTokenizationWithoutAuthorisation, PaymentApi.customerTokenizationWithoutAuthorisation),
    (Constants.paymentCustomerToken, PaymentApi.customerToken),
    (Constants.paymentGlobalInstallmentPaymentPlan, PaymentApi.globalInstallmentPaymentPlan),
    (Constants.paymentLocalInstallmentPaymentPlan, PaymentApi.localInstallmentPaymentPlan),
    (Constants.paymentRecurringPaymentPlan, PaymentApi.recurringPaymentPlan),
    (Constants.paymentThirdPartyPayment, PaymentApi.thirdPartyPayment),
    (Constants.paymentUserAddressForPayment, PaymentApi.userAddressForPayment),
    (Constants.paymentOnlineDirectDebit, PaymentApi.onlineDirectDebit),
    (Constants.paymentDeepLinkPayment, PaymentApi.deepLinkPayment),
    (Constants.paymentInternetBanking, PaymentApi.internetBanking),
    (Constants.paymentWebPayment, PaymentApi.webPayment),
    (Constants.paymentPayAtCounter, PaymentApi.payAtCounter),
    (Constants.paymentSelfServiceMachines, PaymentApi.selfServiceMachines),
    (Constants.paymentQRPayment, PaymentApi.qrPayment),
    (Constants.paymentBuyNowPayLater, PaymentApi.buyNowPayLater),
    (Constants.paymentDigitalPayment, PaymentApi.digitalPayment),
    (Constants.paymentLinePay, PaymentApi.linePay),
    (Constants.paymentApplePay, PaymentApi.applePay),
    (Constants.paymentGooglePay, PaymentApi.googlePay),
    (Constants.paymentCardLoyaltyPointPayment, PaymentApi.cardLoyaltyPointPayment),
    (Constants.paymentZaloPay, PaymentApi.zaloPay),
    (Constants.paymentCryptocurrency, PaymentApi.cryptocurrency),
    (Constants.paymentWebPaymentCard, PaymentApi.webPaymentCard)
  ];

  static void showAlertDialog(String title, String content) {

    final BuildContext? globalContext = navigatorKey.currentContext;

    if (globalContext != null) {

      showDialog(
        context: globalContext,
        builder: (BuildContext buildContext) {
          return AlertDialog(
            title: Text(title),
            content: SingleChildScrollView(
              child: Column(mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[Text(content)]
              ),
            ),
            actions: [
              OutlinedButton(child: const Text(Constants.titleClose),
                onPressed: () => Navigator.of(buildContext).pop()
              ),
            ],
          );
        },
      );
    }
  }

  static void backPreviousScreen() {

    final BuildContext? globalContext = navigatorKey.currentContext;

    if (globalContext != null) {

      Navigator.pop(globalContext);
    }
  }

  static void webViewScreen(String url, String? responseCode) {

    final BuildContext? globalContext = navigatorKey.currentContext;

    if (globalContext != null) {

      Navigator.of(globalContext).push(MaterialPageRoute(builder: (context) => WebViewScreen(url: url, responseCode: responseCode)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(Constants.titleAppName),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                TextEditingController textEditingController = TextEditingController(text: paymentToken);
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Payment Token: '),
                      content: TextField(
                        controller: textEditingController,
                        maxLines: 10
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('OK'),
                          onPressed: () {
                            if (textEditingController.text.isNotEmpty) paymentToken = textEditingController.text;
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            )
          ],
        ),
        body: TabBarView(
          children: <Widget>[
            Center(
              child: ListView(
                children: _infoApis.map((item) {
                  return ListTile(
                    title: Text(item.$1.$1, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 17.0)),
                    subtitle: Text(item.$1.$2),
                    leading: const Icon(Icons.info_outlined),
                    trailing: OutlinedButton(onPressed: () => item.$2(), child: const Text(Constants.titleSubmit)),
                  );
                }).toList(),
              ),
            ),
            Center(
              child: ListView(
                children: _paymentApis.map((item) {
                  return ListTile(
                    title: Text(item.$1.$1, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 17.0)),
                    subtitle: Text(item.$1.$2),
                    leading: const Icon(Icons.shopping_cart_outlined),
                    trailing: OutlinedButton(onPressed: () => item.$2(), child: const Text(Constants.titleSubmit)),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
        bottomNavigationBar: const TabBar(
          tabs: <Widget>[
            Tab(icon: Icon(Icons.info)),
            Tab(icon: Icon(Icons.shopping_cart)),
          ],
        ),
      ),
    );
  }
}