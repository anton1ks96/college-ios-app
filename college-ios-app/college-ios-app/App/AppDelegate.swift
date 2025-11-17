//
//  AppDelegate.swift
//  college-ios-app
//
//  Created by pc on 17.11.2025.
//

import UIKit
import MetricKit

class AppDelegate: NSObject, UIApplicationDelegate, MXMetricManagerSubscriber {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        MXMetricManager.shared.add(self)
        return true
    }
}
