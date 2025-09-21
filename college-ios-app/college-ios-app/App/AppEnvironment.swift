//
//  AppEnvironment.swift
//  college-ios-app
//
//  Created by pc on 21.09.2025.
//

import Foundation

enum AppEnvironment {
    static let baseURL: URL = {
        guard let urlString = Bundle.main.object(forInfoDictionaryKey: "BaseURL") as? String,
              let url = URL(string: urlString) else {
            fatalError("BaseURL is not set or invalid in Info.plist")
        }
        return url
    }()
}
