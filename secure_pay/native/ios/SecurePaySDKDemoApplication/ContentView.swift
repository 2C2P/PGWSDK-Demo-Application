//
//  ContentView.swift
//  SecurePaySDKDemoApplication
//
//  Created by DavidBilly on 12/2/25.
//

import SwiftUI
import SecurePay

struct ContentView: View {
    
    //Step 1 : Initialize SecurePay SDK
    private let sdk: SecurePaySDK = SecurePaySDK(apiEnvironment: SecurePayAPIEnvironment.Sandbox)

    @State private var cardNo: String = "4111111111111111"
    @State private var expiryMonth: String = "12"
    @State private var expiryYear: String = "2027"
    @State private var issuedMonth: String = "1"
    @State private var issuedYear: String = "2023"
    @State private var securityCode: String = "123"
    @State private var pin: String = "123456"
    @State private var merchantId: String = "JT01"
    @State private var paymentToken: String =
    "kSAops9Zwhos8hSTSeLTUZAnjU4qHcwtRio0kjOi6zn6oAbSRy5GcWdqI0PjHS0ANaDffORbaH3sk+PcrpJfwOsNnljxpScgWhqJLSUhSZkUlT2vPadQo6UuuD+7ej1A"
    @State private var securePayToken: String = ""
    @State private var maskedCardNo: String = ""
    
    var body: some View {
        ScrollViewReader { scrollViewProxy in
            ScrollView {
                VStack(alignment: .center, spacing: 16) {
                    Image(systemName: "creditcard.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.blue)
                    LabeledTextField(labelText: "Card No", text: $cardNo)
                        .keyboardType(.numberPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onChange(of: cardNo) { oldValue, newValue in
                            cardNo = String(newValue.prefix(19))
                        }
                    HStack {
                        LabeledTextField(labelText: "Expiry Month", text: $expiryMonth)
                            .keyboardType(.numberPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .onChange(of: expiryMonth) { oldValue, newValue in
                                expiryMonth = String(newValue.prefix(2))
                            }
                        LabeledTextField(labelText: "Expiry Year", text: $expiryYear)
                            .keyboardType(.numberPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .onChange(of: expiryYear) { oldValue, newValue in
                                expiryYear = String(newValue.prefix(4))
                            }
                    }
                    HStack {
                        LabeledTextField(labelText: "Issued Month", text: $issuedMonth)
                            .keyboardType(.numberPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .onChange(of: issuedMonth) { oldValue, newValue in
                                issuedMonth = String(newValue.prefix(2))
                            }
                        LabeledTextField(labelText: "Issued Year", text: $issuedYear)
                            .keyboardType(.numberPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .onChange(of: issuedYear) { oldValue, newValue in
                                issuedYear = String(newValue.prefix(4))
                            }
                    }
                    HStack {
                        LabeledTextField(labelText: "Security Code", text: $securityCode)
                            .keyboardType(.numberPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .onChange(of: securityCode) { oldValue, newValue in
                                securityCode = String(newValue.prefix(4))
                            }
                        LabeledTextField(labelText: "Pin", text: $pin)
                            .keyboardType(.numberPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .onChange(of: pin) { oldValue, newValue in
                                pin = String(newValue.prefix(6))
                            }
                    }
                    LabeledTextField(labelText: "Merchant Id", text: $merchantId)
                        .keyboardType(.default)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onChange(of: merchantId) { oldValue, newValue in
                            merchantId = newValue
                        }
                    VStack(alignment: .leading) {
                        Text("Payment Token")
                            .font(.headline)
                            .padding(.bottom, 5)
                        TextEditor(text: $paymentToken)
                            .border(Color.gray, width: 1)
                            .frame(height: 100)
                    }
                    .padding(.bottom)
                    HStack {
                        Button("Generate Token") {
                            let payload: SecurePayPayload = payload()
                            print("Card No: \(payload.cardNo)")
                            print("Expiry Date: \(payload.expiryMonth) / \(payload.expiryYear)")
                            print("Issued Date: \(payload.issuedMonth) / \(payload.issuedYear)")
                            print("Security Code: \(payload.securityCode) / Pin: \(payload.pin)")
                            print("Merchant ID: \(payload.merchantId) / Payment Token: \(payload.paymentToken)")
                            
                            //Step 3: Generate token.
                            securePayToken = sdk.token(payload)
                        }
                        .buttonStyle(.bordered)
                        Button("Masked Card No") {
                            maskedCardNo = payload().maskedCardNo()
                        }
                        .buttonStyle(.bordered)
                    }
                    Text("Masked Card No: \(maskedCardNo)")
                        .textSelection(.enabled)
                    Text("Secure Pay Token: \(securePayToken)")
                        .textSelection(.enabled)
                    Rectangle()
                        .fill(Color.clear)
                        .frame(width: 1, height: 1)
                        .id("bottom-empty-ui")
                }
                .padding()
            }
            .onChange(of: securePayToken) { oldValue, newValue in
                if !securePayToken.isEmpty {
                    DispatchQueue.main.async {
                        withAnimation {
                            scrollViewProxy.scrollTo("bottom-empty-ui", anchor: .bottom)
                        }
                    }
                }
            }
        }
    }
    
    func payload() -> SecurePayPayload {
    
        //Step 2: Construct payload.
        let payload: SecurePayPayload = SecurePayPayload()
        payload.cardNo = cardNo
        payload.expiryMonth = Int(expiryMonth) ?? 0
        payload.expiryYear = Int(expiryYear) ?? 0
        payload.issuedMonth = Int(issuedMonth) ?? 0
        payload.issuedYear = Int(issuedYear) ?? 0
        payload.securityCode = securityCode
        payload.pin = pin
        
        //Note: merchantId or paymentToken one of them is required.
        payload.merchantId = merchantId
        payload.paymentToken = paymentToken
        
        return payload
    }
}

struct LabeledTextField: View {
    
    let labelText: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading) {
            Text(labelText)
                .font(.headline)
            TextField(labelText, text: $text)
        }
    }
}

#Preview {
    ContentView()
}
