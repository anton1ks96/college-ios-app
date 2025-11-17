//
//  AppDelegate.swift
//  college-ios-app
//
//  Created by pc on 17.11.2025.
//

import UIKit
import MetricKit
import Firebase

class AppDelegate: NSObject, UIApplicationDelegate, MXMetricManagerSubscriber {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        
        if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
           let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
#if DEBUG
            let environment = "debug"
#else
            let environment = "production"
#endif
            
            CrashlyticsLogger.setAppState(
                appVersion: appVersion,
                buildNumber: buildNumber,
                environment: environment
            )
        }
        
        MXMetricManager.shared.add(self)
        return true
    }
}
