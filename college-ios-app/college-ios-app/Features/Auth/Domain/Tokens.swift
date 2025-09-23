//
//  Tokens.swift
//  college-ios-app
//
//  Created by pc on 24.09.2025.
//

import Foundation

public struct Tokens: Codable, Equatable {
    public let accessToken: String
    public let refreshToken: String?
    public let accessExpiration: Date
}

public enum AuthError: Error, LocalizedError, Equatable {
    case noAccess
    case noRefresh
    case unauthorized
    case server(String)

    public var errorDescription: String? {
        switch self {
        case .noAccess: return "No access token"
        case .noRefresh: return "No refresh token"
        case .unauthorized: return "Unauthorized"
        case .server(let msg): return msg
        }
    }
}
