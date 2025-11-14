//
//  AuthSession.swift
//  college-ios-app
//
//  Created by pc on 18.10.2025.
//

import Foundation

public actor AuthSession {
    // Runtime
    private(set) var accessToken: String?
    private(set) var accessExpiry: Date?
    private(set) var refreshExpiry: Date?
    private(set) var currentUser: User?
    
    // Persistent
    private let refreshStorage: RefreshTokenStorage
    
    public init(refreshStorage: RefreshTokenStorage) {
        self.refreshStorage = refreshStorage
    }
    
    public func setLoggedIn(signIn: SignInResponse) async throws {
        accessToken = signIn.accessToken
        accessExpiry = Date().addingTimeInterval(signIn.accessExpiresIn)
        refreshExpiry = Date().addingTimeInterval(signIn.refreshExpiresIn)
        currentUser = signIn.user
        try await refreshStorage.save(signIn.refreshToken)
    }
    
    public func updateAfterRefresh(_ r: RefreshResponse) async throws {
        accessToken = r.accessToken
        accessExpiry = Date().addingTimeInterval(r.accessExpiresIn)
        refreshExpiry = Date().addingTimeInterval(r.refreshExpiresIn)
        try await refreshStorage.save(r.refreshToken)
    }
    
    public func updateAfterAccessRefresh(_ r: AccessTokenResponse) async throws {
        accessToken = r.accessToken
        accessExpiry = Date().addingTimeInterval(TimeInterval(r.expiresIn))
        currentUser = r.user
    }
    
    public func updateAfterRefreshRefresh(_ r: RefreshTokenResponse) async throws {
        refreshExpiry = Date().addingTimeInterval(TimeInterval(r.expiresIn))
        try await refreshStorage.save(r.refreshToken)
    }
    
    public func logoutLocal() async throws {
        accessToken = nil
        accessExpiry = nil
        refreshExpiry = nil
        currentUser = nil
        try await refreshStorage.delete()
    }
    
    public func refreshToken() async throws -> String {
        guard let token = try await refreshStorage.load() else { throw APIError.missingRefreshToken }
        return token
    }
    
    public func isAccessTokenExpiringSoon(leeway: TimeInterval = 60) -> Bool {
        guard let exp = accessExpiry else { return true }
        return Date().addingTimeInterval(leeway) >= exp
    }
    
    public func isRefreshTokenExpiringSoon(daysThreshold: Int = 7) -> Bool {
        guard let exp = refreshExpiry else { return false }
        let threshold = TimeInterval(daysThreshold * 24 * 60 * 60)
        return Date().addingTimeInterval(threshold) >= exp
    }
    
    public func setCurrentUser(_ user: User) {
        currentUser = user
    }
}
