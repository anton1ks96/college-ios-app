//
//  AppDependencies.swift
//  college-ios-app
//

import Foundation

enum AppDependencies {
    static let refreshStorage = KeychainTokenStorage()
    static let authSession = AuthSession(refreshStorage: refreshStorage)
    static let decoder = JSONDecoder()

    static let authClient = AFHTTPClient(baseURL: AppEnvironment.authBaseURL, decoder: decoder)
    static let authAPI = AuthAPI(client: authClient)
    static let authService = AuthService(api: authAPI, session: authSession)

    static let interceptor = AuthRequestInterceptor(authService: authService)
    static let authenticatedClient = AFHTTPClient(
        baseURL: AppEnvironment.scheduleBaseURL,
        decoder: decoder,
        interceptor: interceptor
    )
}
