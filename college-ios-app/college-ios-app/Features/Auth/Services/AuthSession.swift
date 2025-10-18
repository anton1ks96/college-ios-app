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
    private(set) var currentUser: User?
    
    // Persistent
    private let refreshStorage: RefreshTokenStorage
    
    public init(refreshStorage: RefreshTokenStorage) {
        self.refreshStorage = refreshStorage
    }
    
    public func setLoggedIn(signIn: SignInResponse) async throws {
        accessToken = signIn.accessToken
        accessExpiry = Date().addingTimeInterval(signIn.accessExpiresIn)
        currentUser = signIn.user
        try await refreshStorage.save(signIn.refreshToken)
    }
    
    public func updateAfterRefresh(_ r: RefreshResponse) async throws {
        accessToken = r.accessToken
        accessExpiry = Date().addingTimeInterval(r.refreshExpiresIn)
        try await refreshStorage.save(r.refreshToken)
    }
    
    public func logoutLocal() async throws {
        accessToken = nil
        accessExpiry = nil
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
    
    public func setCurrentUser(_ user: User) {
        currentUser = user
    }
}
