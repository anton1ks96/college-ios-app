//
//  PreviewMocks.swift
//  college-ios-app
//
//  Created by pc on 25.09.2025.
//

#if DEBUG
import Foundation

final class InMemoryTokenStorage: RefreshTokenStorage {
    private let lock = NSLock()
    nonisolated(unsafe) private var stored: StoredRefreshToken?

    init(stored: StoredRefreshToken? = nil) {
        self.stored = stored
    }

    func save(_ token: StoredRefreshToken) throws {
        lock.withLock { stored = token }
    }

    func load() throws -> StoredRefreshToken? {
        lock.withLock { stored }
    }

    func delete() throws {
        lock.withLock { stored = nil }
    }
}

final class MockAuthAPI: AuthAPIProtocol {
    private let user: User

    init(user: User = PreviewMocks.sampleUser) {
        self.user = user
    }

    func signIn(username: String, password: String) async throws -> SignInResponse {
        SignInResponse(
            accessToken: "preview_access_token",
            refreshToken: "preview_refresh_token",
            accessExpiresIn: 3600,
            refreshExpiresIn: 60 * 60 * 24 * 30,
            user: user
        )
    }

    func getAccessToken(refreshToken: String) async throws -> AccessTokenResponse {
        AccessTokenResponse(accessToken: "preview_access_token", expiresIn: 3600, user: user)
    }

    func refreshRefreshToken(refreshToken: String) async throws -> RefreshTokenResponse {
        RefreshTokenResponse(refreshToken: "preview_refresh_token", expiresIn: 60 * 60 * 24 * 30)
    }

    func signOut(refreshToken: String) async throws {}
}

enum PreviewMocks {
    static let sampleUser = User(
        id: "i24s0291",
        username: "i24s0291",
        role: "student",
        academicGroup: "ИТ24-11",
        profile: "BE",
        subgroup: nil,
        englishGroup: "B1.21"
    )

    @MainActor
    static func sessionViewModel(loggedIn: Bool = true) -> SessionViewModel {
        let authSession = AuthSession(refreshStorage: InMemoryTokenStorage())
        let authService = AuthService(api: MockAuthAPI(), session: authSession)
        let viewModel = SessionViewModel(authService: authService, authSession: authSession)
        viewModel.isBootstrapping = false

        if loggedIn {
            Task {
                try? await authService.signIn(username: sampleUser.username, password: "preview")
                await viewModel.syncFromSession()
            }
        }
        return viewModel
    }
}
#endif
