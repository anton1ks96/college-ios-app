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

    static let scheduleClient = AFHTTPClient(baseURL: AppEnvironment.scheduleBaseURL, decoder: decoder)

    static let scheduleRepository: ScheduleRepositoryProtocol = {
        let live = ScheduleRepository(api: ScheduleAPI(client: scheduleClient))
#if DEBUG
        let isPlaceholderHost = AppEnvironment.scheduleBaseURL.host()?.hasSuffix(".invalid") ?? true
        return isPlaceholderHost ? MockScheduleRepository() : live
#else
        return live
#endif
    }()
}
