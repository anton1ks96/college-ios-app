////
////  AppDelegate.swift
////  college-ios-app
////
////  Created by pc on 03.10.2025.
////
//
//import UIKit
//import FirebaseCore
//import FirebaseCrashlytics
//
//class AppDelegate: NSObject, UIApplicationDelegate {
//    
//    // MARK: - UIApplicationDelegate
//    
//    func application(
//        _ application: UIApplication,
//        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
//    ) -> Bool {
//        configureFirebase()
//        startMetricKit()
//        
//        return true
//    }
//    
//    // MARK: - Private Methods
//    
//    private func configureFirebase() {
//        FirebaseApp.configure()
//        
//        Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(true)
//        
//        Crashlytics.crashlytics().setCustomValue(appVersion, forKey: "app_version")
//        Crashlytics.crashlytics().setCustomValue(buildNumber, forKey: "build_number")
//    }
//    
//    private func startMetricKit() {
//        MetricsManager.shared.start()
//    }
//    
//    // MARK: - Computed Properties
//    
//    private var appVersion: String {
//        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
//    }
//    
//    private var buildNumber: String {
//        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
//    }
//}
