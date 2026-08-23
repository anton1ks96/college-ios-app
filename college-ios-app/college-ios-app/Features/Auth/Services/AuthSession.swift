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
        do {
            try refreshStorage.save(
                StoredRefreshToken(token: signIn.refreshToken, expiresAt: refreshExpiry)
            )
        } catch {
            await MainActor.run {
                CrashlyticsLogger.setCustomKeys(["auth_operation": "set_logged_in"])
            }
            throw error
        }
    }
    
    public func updateAfterAccessRefresh(_ r: AccessTokenResponse) async throws {
        accessToken = r.accessToken
        accessExpiry = Date().addingTimeInterval(TimeInterval(r.expiresIn))
        currentUser = r.user
    }
    
    public func updateAfterRefreshRefresh(_ r: RefreshTokenResponse) async throws {
        refreshExpiry = Date().addingTimeInterval(TimeInterval(r.expiresIn))
        do {
            try refreshStorage.save(
                StoredRefreshToken(token: r.refreshToken, expiresAt: refreshExpiry)
            )
        } catch {
            await MainActor.run {
                CrashlyticsLogger.setCustomKeys(["auth_operation": "update_after_refresh_refresh"])
            }
            throw error
        }
    }
    
    public func logoutLocal() async throws {
        accessToken = nil
        accessExpiry = nil
        refreshExpiry = nil
        currentUser = nil
        do {
            try refreshStorage.delete()
        } catch {
            await MainActor.run {
                CrashlyticsLogger.setCustomKeys(["auth_operation": "logout_local"])
            }
            throw error
        }
    }
    
    public func refreshToken() async throws -> String {
        do {
            guard let stored = try refreshStorage.load() else {
                await MainActor.run {
                    CrashlyticsLogger.logAuthError(
                        APIError.missingRefreshToken,
                        operation: "load_refresh_token"
                    )
                }
                throw APIError.missingRefreshToken
            }
            if refreshExpiry == nil {
                refreshExpiry = stored.expiresAt
            }
            return stored.token
        } catch let error as APIError {
            throw error
        } catch {
            await MainActor.run {
                CrashlyticsLogger.setCustomKeys(["auth_operation": "load_refresh_token"])
            }
            throw error
        }
    }
    
    public func isAccessTokenExpiringSoon(leeway: TimeInterval = 60) -> Bool {
        guard let exp = accessExpiry else { return true }
        return Date().addingTimeInterval(leeway) >= exp
    }
    
    public func isRefreshTokenExpiringSoon(daysThreshold: Int = 7) -> Bool {
        if refreshExpiry == nil {
            refreshExpiry = (try? refreshStorage.load())??.expiresAt
        }
        guard let exp = refreshExpiry else { return false }
        let threshold = TimeInterval(daysThreshold * 24 * 60 * 60)
        return Date().addingTimeInterval(threshold) >= exp
    }
    
    public func setCurrentUser(_ user: User) {
        currentUser = user
    }
}
