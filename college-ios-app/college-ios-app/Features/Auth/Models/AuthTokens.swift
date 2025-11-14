//
//  AuthTokens.swift
//  college-ios-app
//
//  Created by pc on 17.10.2025.
//

import Foundation

public struct AuthTokens: Codable, Equatable, Sendable {
    public let accessToken: String
    public let refreshToken: String
    public let accessExpiresIn: TimeInterval
    public let refreshExpiresIn: TimeInterval
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case accessExpiresIn = "access_expires_in"
        case refreshExpiresIn = "refresh_expires_in"
    }
}
