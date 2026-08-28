//
//  AccessTokenResponse.swift
//  college-ios-app
//
//  Created by pc on 20.10.2025.
//

import Foundation

public nonisolated struct AccessTokenResponse: Codable, Sendable {
    public let accessToken: String
    public let expiresIn: Int
    public let user: User

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case expiresIn = "expires_in"
        case user
    }
}
