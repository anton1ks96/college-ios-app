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
            fatalError("BaseScheduleURL is not set or invalid in Info.plist")
        }
        return url
    }()

    static let authBaseURL: URL = {
        guard let urlString = Bundle.main.object(forInfoDictionaryKey: "BaseAuthURL") as? String,
              let url = URL(string: urlString) else {
            fatalError("BaseAuthURL is not set or invalid in Info.plist")
        }
        return url
    }()
}
