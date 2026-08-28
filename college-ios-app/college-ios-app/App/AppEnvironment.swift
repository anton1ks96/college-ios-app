//
//  AppEnvironment.swift
//  college-ios-app
//
//  Created by pc on 21.09.2025.
//

import Foundation

enum AppEnvironment {
    static let scheduleBaseURL: URL = {
        guard let urlString = Bundle.main.object(forInfoDictionaryKey: "BaseScheduleURL") as? String,
              let url = URL(string: urlString) else {
            let message = "BaseScheduleURL is not set or invalid in Info.plist"
            CrashlyticsLogger.logFatalError(
                message,
                customKeys: [
                    "config_key": "BaseScheduleURL",
                    "url_string": Bundle.main.object(forInfoDictionaryKey: "BaseScheduleURL") as? String ?? "nil"
                ]
            )
            fatalError(message)
        }
        return url
    }()
    
    static let authBaseURL: URL = {
        guard let urlString = Bundle.main.object(forInfoDictionaryKey: "BaseAuthURL") as? String,
              let url = URL(string: urlString) else {
            let message = "BaseAuthURL is not set or invalid in Info.plist"
            CrashlyticsLogger.logFatalError(
                message,
                customKeys: [
                    "config_key": "BaseAuthURL",
                    "url_string": Bundle.main.object(forInfoDictionaryKey: "BaseAuthURL") as? String ?? "nil"
                ]
            )
            fatalError(message)
        }
        return url
    }()

    static var usesMockData: Bool {
#if DEBUG
        scheduleBaseURL.host()?.hasSuffix(".invalid") ?? true
#else
        false
#endif
    }
}
