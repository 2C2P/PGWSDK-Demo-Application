//
//  AppDelegate.swift
//  PGWSDKDemoApplication
//
//  Created by DavidBilly on 1/6/25.
//

import UIKit
import PGW
import PGWHelper

class AppDelegate: UIResponder, UIApplicationDelegate {
     
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        let pgwsdkParams: PGWSDKParams = PGWSDKParamsBuilder(apiEnvironment: APIEnvironment.Sandbox)
                                        .log(true)
                                        .build()
 
        PGWSDK.initialize(params: pgwsdkParams)
        
        return true
    }
    
    //For SwiftUI need handle within scene. ContentView().onOpenURL{ url in }
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {

        PGWSDKHelper.shared.universalPaymentResultObserver(url: url)
         
        return true
    }
}
