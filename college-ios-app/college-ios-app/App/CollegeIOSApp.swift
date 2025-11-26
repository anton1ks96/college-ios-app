//
//  CollegeIOSApp.swift
//  college-ios-app
//
//  Created by pc on 21.09.2025.
//

import SwiftUI

// MARK: - Shared Dependencies

private enum SharedDependencies {
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
        SessionViewModel(
            authService: SharedDependencies.authService,
            authSession: SharedDependencies.authSession
        )
    }()

    @StateObject private var attendanceViewModel: AttendanceViewModel = {
        let attendanceAPI = AttendanceAPI(client: SharedDependencies.authenticatedClient)
        return AttendanceViewModel(api: attendanceAPI)
    }()

    @StateObject private var performanceViewModel: PerformanceViewModel = {
        let performanceAPI = PerformanceAPI(client: SharedDependencies.authenticatedClient)
        return PerformanceViewModel(api: performanceAPI)
    }()

    @StateObject private var streakViewModel: StreakViewModel = {
        let streakAPI = StreakAPI(client: SharedDependencies.authenticatedClient)
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
