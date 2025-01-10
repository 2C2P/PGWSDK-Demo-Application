//
//  ContentView.swift
//  PGWSDKDemoApplication
//
//  Created by DavidBilly on 1/6/25.
//

import SwiftUI
import WebKit
import PGW

//Reference: https://developer.2c2p.com/docs/api-payment-token
var paymentToken = "kSAops9Zwhos8hSTSeLTUYAajTFNGzaMYz4TNdzxItHe7yVdY7XfZtllOJDDV7PgzU6DIhfjAggfeZ4KqxOsWAwLY57VYXf/L//PK/avE/tFIFgDvJF8snmaHDbOVawr"

struct ListItem: Identifiable {
    
    let id = UUID()
    let content: (String, String)
    let method: (String, String, [Any])
    
    init(_ content: (String, String), _ method: (String, String, [Any])) {
        
        self.content = content
        self.method = method
    }
}

struct ListView: View {
    
    let apis: [ListItem]
    let icon: String
    
    var body: some View {
        NavigationView {
            List(apis) { api in
                HStack {
                    Image(systemName: icon)
                        .frame(maxWidth: 30, alignment: .leading)
                    VStack(alignment: .leading) {
                        Text(api.content.0)
                            .font(.headline)
                        Text(api.content.1)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .frame(alignment: .center)
                    Spacer()
                    Button("Submit") {
                        do {
                            _ = try ReflectionHelper.callStaticMethod(
                                className: api.method.0,
                                methodName: api.method.1,
                                parameters: api.method.2.isEmpty ? nil : api.method.2
                            )
                        } catch {
                            print("Error: \(error.localizedDescription)")
                        }
                    }
                    .buttonStyle(.bordered)
                    .frame(alignment: .trailing)
                }
                .padding(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
            }
        }
    }
}

struct ContentView: View {
    
    @ObservedObject private var paymentApiObservedObject = PaymentApi.shared
    @State private var selectedTab = 0
    @State private var showingPopupDialog = false
    @State private var inputText = paymentToken
    
    private static let infoApiIcon = "exclamationmark.octagon"
    private static let paymentApiIcon = "cart"
    
    let infoApis = [
        ListItem(Constants.apiClientId, ("InfoApi", "clientId", [])),
        ListItem(Constants.apiConfiguration, ("InfoApi", "configuration", [])),
        ListItem(Constants.apiPaymentOption, ("InfoApi", "paymentOption", [])),
        ListItem(Constants.apiPaymentOptionDetail, ("InfoApi", "paymentOptionDetail", [])),
        ListItem(Constants.apiCustomerTokenInfo, ("InfoApi", "customerTokenInfo", [])),
        ListItem(Constants.apiExchangeRate, ("InfoApi", "exchangeRate", [])),
        ListItem(Constants.apiUserPreference, ("InfoApi", "userPreference", [])),
        ListItem(Constants.apiTransactionStatus, ("InfoApi", "transactionStatus", [paymentToken])),
        ListItem(Constants.apiSystemInitialization, ("InfoApi", "systemInitialization", [])),
        ListItem(Constants.apiPaymentNotification, ("InfoApi", "paymentNotification", [])),
        ListItem(Constants.apiCancelTransaction, ("InfoApi", "cancelTransaction", [])),
        ListItem(Constants.apiLoyaltyPointInfo, ("InfoApi", "loyaltyPointInfo", []))
    ]
    
    let paymentApis = [
        ListItem(Constants.paymentUI, ("PaymentApi", "paymentUI", [])),
        ListItem(Constants.paymentGlobalCreditDebitCard, ("PaymentApi", "globalCreditDebitCard", [])),
        ListItem(Constants.paymentLocalCreditDebitCard, ("PaymentApi", "localCreditDebitCard", [])),
        ListItem(Constants.paymentCustomerTokenization, ("PaymentApi", "customerTokenization", [])),
        ListItem(Constants.paymentCustomerTokenizationWithoutAuthorisation, ("PaymentApi", "customerTokenizationWithoutAuthorisation", [])),
        ListItem(Constants.paymentCustomerToken, ("PaymentApi", "customerToken", [])),
        ListItem(Constants.paymentGlobalInstallmentPaymentPlan, ("PaymentApi", "globalInstallmentPaymentPlan", [])),
        ListItem(Constants.paymentLocalInstallmentPaymentPlan, ("PaymentApi", "localInstallmentPaymentPlan", [])),
        ListItem(Constants.paymentRecurringPaymentPlan, ("PaymentApi", "recurringPaymentPlan", [])),
        ListItem(Constants.paymentThirdPartyPayment, ("PaymentApi", "thirdPartyPayment", [])),
        ListItem(Constants.paymentUserAddressForPayment, ("PaymentApi", "userAddressForPayment", [])),
        ListItem(Constants.paymentOnlineDirectDebit, ("PaymentApi", "onlineDirectDebit", [])),
        ListItem(Constants.paymentDeepLinkPayment, ("PaymentApi", "deepLinkPayment", [])),
        ListItem(Constants.paymentInternetBanking, ("PaymentApi", "internetBanking", [])),
        ListItem(Constants.paymentWebPayment, ("PaymentApi", "webPayment", [])),
        ListItem(Constants.paymentPayAtCounter, ("PaymentApi", "payAtCounter", [])),
        ListItem(Constants.paymentSelfServiceMachines, ("PaymentApi", "selfServiceMachines", [])),
        ListItem(Constants.paymentQRPayment, ("PaymentApi", "qrPayment", [])),
        ListItem(Constants.paymentBuyNowPayLater, ("PaymentApi", "buyNowPayLater", [])),
        ListItem(Constants.paymentDigitalPayment, ("PaymentApi", "digitalPayment", [])),
        ListItem(Constants.paymentLinePay, ("PaymentApi", "linePay", [])),
        ListItem(Constants.paymentApplePay, ("PaymentApi", "applePay", [])),
        ListItem(Constants.paymentCardLoyaltyPointPayment, ("PaymentApi", "cardLoyaltyPointPayment", [])),
        ListItem(Constants.paymentZaloPay, ("PaymentApi", "zaloPay", [])),
        ListItem(Constants.paymentCryptocurrency, ("PaymentApi", "cryptocurrency", [])),
        ListItem(Constants.paymentWebPaymentCard, ("PaymentApi", "webPaymentCard", []))
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 0) {
                    HStack {
                        Text("PGW SDK Demo Application")
                            .font(.headline)
                            .foregroundColor(.primary)
                        Spacer()
                        Button(action: {
                            showingPopupDialog = true
                        }) {
                            Image(systemName: "gear")
                                .font(.system(size: 25, weight: .semibold))
                                .foregroundColor(.primary)
                        }
                    }
                    .padding(.horizontal)
                    .frame(height: 44)
                    TabView(selection: $selectedTab) {
                        ListView(apis: infoApis, icon: ContentView.infoApiIcon)
                            .tabItem {
                                Image(systemName: "\(ContentView.infoApiIcon).fill")
                                Text("Info")
                            }
                            .tag(0)
                        
                        ListView(apis: paymentApis, icon: ContentView.paymentApiIcon)
                            .tabItem {
                                Image(systemName: "\(ContentView.paymentApiIcon).fill")
                                Text("Payment")
                            }
                            .tag(1)
                    }
                }
                
                .navigationDestination(isPresented: paymentApiObservedObject.webviewScreen.0) {
                    WebView()
                }
                
                if showingPopupDialog {
                    
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture {
                            showingPopupDialog = false
                        }
                    
                    PopupDialog(presented: $showingPopupDialog, inputText: $inputText)
                        .transition(.scale)
                        .animation(.easeInOut, value: showingPopupDialog)
                }
            }
        }
    }
}

struct WebView: UIViewRepresentable {
    
    private let url: String = PaymentApi.shared.webviewScreen.1
    private let responseCode: String = PaymentApi.shared.webviewScreen.2
    private let webView: WKWebView
    private var pgwWebViewNavigationDelegate: PGWWebViewNavigationDelegate?
    private static var timer: Timer?
    
    init() {
        
        self.webView = WKWebView(frame: UIScreen.main.bounds)
        
        if #available(iOS 14, *) {
            
            let preferences = WKWebpagePreferences()
            preferences.allowsContentJavaScript = true
            webView.configuration.defaultWebpagePreferences = preferences
        } else {
            
            webView.configuration.preferences.javaScriptEnabled = true
            webView.configuration.preferences.javaScriptCanOpenWindowsAutomatically = true
        }
        
        self.webView.navigationDelegate = self.pgwTransactionResultCallback()
        
        if self.responseCode == APIResponseCode.TransactionQRPayment {
            
            WebView.timer = Timer.scheduledTimer(withTimeInterval: 15.0, repeats: true) { timer in
                
                //Reference: https://developer.2c2p.com/docs/api-sdk-transaction-status-inquiry
                //Step 1: Generate payment token.
                let paymentToken: String = paymentToken
                
                //Step 2: Construct transaction status inquiry request.
                let transactionStatusRequest: TransactionStatusRequest = TransactionStatusRequest(paymentToken: paymentToken)
                transactionStatusRequest.additionalInfo = true
                
                //Step 3: Retrieve transaction status inquiry response.
                PGWSDK.shared.transactionStatus(transactionStatusRequest: transactionStatusRequest, { (response: TransactionStatusResponse) in

                    if response.responseCode != APIResponseCode.TransactionInProgress {
                        
                        timer.invalidate()
                        
                        PaymentApi.shared.webviewScreen = (Binding.constant(false), "", "")
                        
                        ContentView.showAlertDialog(Constants.apiTransactionStatus.0, TransactionStatusResponse.parse(response))
                    } else {
                        
                        //Continue do a looping query or long polling to get transaction status until user scan the QR and make payment
                    }
                }) { (error: NSError) in
                    
                    timer.invalidate()
                    
                    //Get error response and display error.
                    ContentView.showAlertDialog(Constants.apiTransactionStatus.0, "Error: \(error.domain)")
                }
            }
        }
    }
    
    //Reference : https://developer.2c2p.com/docs/api-sdk-transaction-status-inquiry
    private mutating func pgwTransactionResultCallback() -> PGWWebViewNavigationDelegate {
        
        self.pgwWebViewNavigationDelegate = PGWWebViewNavigationDelegate({ (paymentToken: String) in
            
            //Do Transaction Status Inquiry API and close this WebView.
            InfoApi.transactionStatus(paymentToken)
            
            PaymentApi.shared.webviewScreen = (Binding.constant(false), "", "")
        })
        
        self.pgwWebViewNavigationDelegate?.navigationCallback(didStartProvisionalNavigation: { (url: String) in
            
            print("PGWWebViewNavigationDelegate didStartProvisionalNavigation : \(url)")
        }, decidePolicyForNavigationAction: { (url: String) in
            
            print("PGWWebViewNavigationDelegate decidePolicyForNavigationAction : \(url)")
        }, didFinishNavigation: { (url: String) in
            
            print("PGWWebViewNavigationDelegate didFinishNavigation : \(url)")
        })
        
        return self.pgwWebViewNavigationDelegate!
    }
    
    func makeUIView(context: Context) -> WKWebView {
        
        return self.webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        
        self.webView.load(URLRequest(url: URL(string: self.url)!))
    }
    
    static func dismantleUIView(_ uiView: WKWebView, coordinator: Coordinator) {

        WebView.timer?.invalidate()
        WebView.timer = nil
    }
}

struct PopupDialog: View {
    
    @Binding var presented: Bool
    @Binding var inputText: String
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Enter Payment Token: ")
                .font(.headline)
                .padding(EdgeInsets(top: 20, leading: 15, bottom: 0, trailing: 0))
                .frame(maxWidth: .infinity, alignment: .topLeading)
            TextField("", text: $inputText)
                .multilineTextAlignment(.leading)
                .lineLimit(10)
                .frame(height: 200)
                .foregroundStyle(Color.clear)
                .overlay {
                    TextEditor(text: $inputText)
                        .cornerRadius(5)
                        .padding(.horizontal)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(.black, lineWidth: 1 / 3)
                                .opacity(0.3)
                        )
                }
                .padding(.horizontal)
            Button("OK") {
                presented = false
                paymentToken = $inputText.wrappedValue
            }
            .buttonStyle(.bordered)
            .padding(EdgeInsets(top: 10, leading: 0, bottom: 20, trailing: 20))
            .frame(maxWidth: .infinity, alignment: .bottomTrailing)
        }
        .frame(width: 300)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 10)
        .padding()
    }
}

extension ContentView {

    static func viewController() -> UIViewController? {
        
        return UIApplication
            .shared
            .connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }?
            .rootViewController
    }
    
    static func showAlertDialog(_ title: String, _ message: String) {
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.left
        
        let messageText = NSAttributedString(
            string: message,
            attributes: [
                NSAttributedString.Key.paragraphStyle: paragraphStyle,
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13)
            ]
        )
        
        let dialog = UIAlertController(
            title: title,
            message: "",
            preferredStyle:UIAlertController.Style.alert
        )
        dialog.setValue(messageText, forKey: "attributedMessage")
        dialog.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        
        DispatchQueue.main.async {
            viewController()?.present(dialog, animated: true, completion: {})
        }
    }
}

#Preview {
    ContentView()
}
