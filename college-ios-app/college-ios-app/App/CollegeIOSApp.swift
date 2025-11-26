//
//  CollegeIOSApp.swift
//  college-ios-app
//
//  Created by pc on 21.09.2025.
//

import SwiftUI

@main
struct CollegeIOSApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @StateObject private var scheduleViewModel: ScheduleViewModel = {
        let client = AFHTTPClient(baseURL: AppEnvironment.scheduleBaseURL)
        let api = ScheduleAPI(client: client)
        let scheduleRepo = ScheduleRepository(api: api)
        let settingsRepo = UserSettingsRepository()

        return ScheduleViewModel(
            repository: scheduleRepo,
            settingsRepository: settingsRepo
        )
    }()

    @StateObject private var sessionViewModel: SessionViewModel = {
        let refreshStorage = KeychainTokenStorage()
        let authSession = AuthSession(refreshStorage: refreshStorage)

        let decoder = JSONDecoder()

        let client = AFHTTPClient(baseURL: AppEnvironment.authBaseURL, decoder: decoder)
        let api = AuthAPI(client: client)
        let authService = AuthService(api: api, session: authSession)

        return SessionViewModel(authService: authService, authSession: authSession)
    }()

    @StateObject private var attendanceViewModel: AttendanceViewModel = {
        let refreshStorage = KeychainTokenStorage()
        let authSession = AuthSession(refreshStorage: refreshStorage)

        let decoder = JSONDecoder()

        let client = AFHTTPClient(baseURL: AppEnvironment.authBaseURL, decoder: decoder)
        let api = AuthAPI(client: client)
        let authService = AuthService(api: api, session: authSession)

        let interceptor = AuthRequestInterceptor(authService: authService)
        let authenticatedClient = AFHTTPClient(
            baseURL: AppEnvironment.scheduleBaseURL,
            decoder: decoder,
            interceptor: interceptor
        )

        let attendanceAPI = AttendanceAPI(client: authenticatedClient)
        return AttendanceViewModel(api: attendanceAPI)
    }()

    @StateObject private var performanceViewModel: PerformanceViewModel = {
        let refreshStorage = KeychainTokenStorage()
        let authSession = AuthSession(refreshStorage: refreshStorage)

        let decoder = JSONDecoder()

        let client = AFHTTPClient(baseURL: AppEnvironment.authBaseURL, decoder: decoder)
        let api = AuthAPI(client: client)
        let authService = AuthService(api: api, session: authSession)

        let interceptor = AuthRequestInterceptor(authService: authService)
        let authenticatedClient = AFHTTPClient(
            baseURL: AppEnvironment.scheduleBaseURL,
            decoder: decoder,
            interceptor: interceptor
        )

        let performanceAPI = PerformanceAPI(client: authenticatedClient)
        return PerformanceViewModel(api: performanceAPI)
    }()

    @StateObject private var streakViewModel: StreakViewModel = {
        let refreshStorage = KeychainTokenStorage()
        let authSession = AuthSession(refreshStorage: refreshStorage)

        let decoder = JSONDecoder()

        let client = AFHTTPClient(baseURL: AppEnvironment.authBaseURL, decoder: decoder)
        let api = AuthAPI(client: client)
        let authService = AuthService(api: api, session: authSession)

        let interceptor = AuthRequestInterceptor(authService: authService)
        let authenticatedClient = AFHTTPClient(
            baseURL: AppEnvironment.scheduleBaseURL,
            decoder: decoder,
            interceptor: interceptor
        )

        let streakAPI = StreakAPI(client: authenticatedClient)
        return StreakViewModel(api: streakAPI)
    }()

    @AppStorage("selectedTheme") private var selectedTheme: AppTheme = .system

    var body: some Scene {
        WindowGroup {
            RootView(
                sessionViewModel: sessionViewModel,
                scheduleViewModel: scheduleViewModel,
                attendanceViewModel: attendanceViewModel,
                performanceViewModel: performanceViewModel,
                streakViewModel: streakViewModel
            )
            .preferredColorScheme(selectedTheme.colorScheme)
            .environmentObject(sessionViewModel)
            .environmentObject(streakViewModel)
            .task {
                sessionViewModel.bootstrapAutoLogin()
            }
        }
    }
}
