//
//  Application.swift
//  PGWSDKDemoApplication
//
//  Created by DavidBilly on 1/6/25.
//

import SwiftUI
import PGWHelper

@main
struct Application: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    //Reference: https://developer.2c2p.com/docs/sdk-references-handle-deeplink-payment-flow-by-pgw-sdk-helper
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL{ url in
                    PGWSDKHelper.shared.universalPaymentResultObserver(url: url)
                }
        }
    }
}
