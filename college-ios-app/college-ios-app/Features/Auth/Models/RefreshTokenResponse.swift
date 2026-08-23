//
//  RefreshTokenResponse.swift
//  college-ios-app
//
//  Created by pc on 20.10.2025.
//

import Foundation

public nonisolated struct RefreshTokenResponse: Codable, Sendable {
    public let refreshToken: String
    public let expiresIn: Int

    enum CodingKeys: String, CodingKey {
        case refreshToken = "refresh_token"
        case expiresIn = "expires_in"
    }
}
