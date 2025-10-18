//
//  AuthService.swift
//  college-ios-app
//
//  Created by pc on 18.10.2025.
//

import Foundation

public final class AuthService: @unchecked Sendable {
    private let api: AuthAPI
    private let session: AuthSession
    
    public init(api: AuthAPI, session: AuthSession) {
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
            let refreshed = try await api.refresh(refreshToken: refresh)
            try await session.updateAfterRefresh(refreshed)
            
            if loadUser, let access = await session.accessToken {
                let user = try await api.currentUser(accessToken: access)
                await setUser(user)
            }
        } catch {}
    }
    
    public func signOut() async {
        do {
            let refresh = try await session.refreshToken()
            try await api.signOut(refreshToken: refresh)
        } catch {}
        do { try await session.logoutLocal() } catch {}
    }
    
    public func ensureValidAccessToken() async throws -> String {
        if let token = await session.accessToken {
            let isExpiring = await session.isAccessTokenExpiringSoon()
            if !isExpiring {
                return token
            }
        }
        let refresh = try await session.refreshToken()
        let resp = try await api.refresh(refreshToken: refresh)
        try await session.updateAfterRefresh(resp)
        guard let token = await session.accessToken else { throw APIError.refreshFailed }
        return token
    }
    
    public func reloadCurrentUser() async throws -> User {
        let access = try await ensureValidAccessToken()
        let user = try await api.currentUser(accessToken: access)
        await setUser(user)
        return user
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
