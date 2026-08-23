//
//  AuthService.swift
//  college-ios-app
//
//  Created by pc on 18.10.2025.
//

import Foundation

public actor AuthService {
    private let api: AuthAPIProtocol
    private let session: AuthSession

    public init(api: AuthAPIProtocol, session: AuthSession) {
        self.api = api
        self.session = session
    }
    
    // MARK: - Public API
    
    public func signIn(username: String, password: String) async throws {
        let resp = try await api.signIn(username: username, password: password)
        try await session.setLoggedIn(signIn: resp)
    }
    
    public func bootstrapAutoLogin(loadUser: Bool = true) async {
        do {
            let refresh = try await session.refreshToken()
            
            if await session.isRefreshTokenExpiringSoon() {
                let newRefreshResp = try await api.refreshRefreshToken(refreshToken: refresh)
                try await session.updateAfterRefreshRefresh(newRefreshResp)
            }
            
            let currentRefresh = try await session.refreshToken()
            let accessResp = try await api.getAccessToken(refreshToken: currentRefresh)
            try await session.updateAfterAccessRefresh(accessResp)
        } catch {
            CrashlyticsLogger.logAuthError(
                error,
                operation: "bootstrap_auto_login"
            )
            CrashlyticsLogger.recordBreadcrumb("Auto-login failed on app start")
        }
    }
    
    public func signOut() async {
        do {
            let refresh = try await session.refreshToken()
            try await api.signOut(refreshToken: refresh)
        } catch {
            CrashlyticsLogger.logAuthError(
                error,
                operation: "signout_api"
            )
        }
        do {
            try await session.logoutLocal()
        } catch {
            CrashlyticsLogger.logAuthError(
                error,
                operation: "signout_local_cleanup"
            )
        }
    }
    
    public func ensureValidAccessToken() async throws -> String {
        if await session.isRefreshTokenExpiringSoon() {
            do {
                let refresh = try await session.refreshToken()
                let newRefreshResp = try await api.refreshRefreshToken(refreshToken: refresh)
                try await session.updateAfterRefreshRefresh(newRefreshResp)
            } catch {
                CrashlyticsLogger.logAuthError(
                    error,
                    operation: "refresh_token_renewal"
                )
            }
        }
        
        if let token = await session.accessToken {
            let isExpiring = await session.isAccessTokenExpiringSoon()
            if !isExpiring {
                return token
            }
        }
        
        let refresh = try await session.refreshToken()
        let accessResp = try await api.getAccessToken(refreshToken: refresh)
        try await session.updateAfterAccessRefresh(accessResp)
        guard let token = await session.accessToken else { throw APIError.refreshFailed }
        return token
    }
    
    // MARK: - Private
    
    private func setUser(_ user: User) async {
        await session.setCurrentUser(user)
    }
}

// MARK: - Factory

public extension AuthService {
    static func create(baseAuthURL: URL, refreshStorage: RefreshTokenStorage = KeychainTokenStorage()) -> AuthService {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        let client = AFHTTPClient(
            baseURL: baseAuthURL,
            decoder: decoder
        )
        
        let api = AuthAPI(client: client)
        
        let session = AuthSession(refreshStorage: refreshStorage)
        
        return AuthService(api: api, session: session)
    }
}
