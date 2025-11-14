//
//  AuthAPIConfig.swift
//  college-ios-app
//
//  Created by pc on 18.10.2025.
//

import Foundation

public struct AuthAPIConfig: Sendable {
    public let baseAuthURL: URL

    public init(baseAuthURL: URL) {
        self.baseAuthURL = baseAuthURL
    }
}
