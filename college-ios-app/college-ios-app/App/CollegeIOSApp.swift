//
//  CollegeIOSApp.swift
//  college-ios-app
//
//  Created by pc on 21.09.2025.
//

import SwiftUI

@main
struct CollegeIOSApp: App {
    //    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    @StateObject private var scheduleViewModel: ScheduleViewModel = {
        let client = AFHTTPClient(baseURL: AppEnvironment.baseURL)
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

        let client = AFHTTPClient(baseURL: AppEnvironment.baseURL, decoder: decoder)
        let api = AuthAPI(client: client)
        let authService = AuthService(api: api, session: authSession)

        return SessionViewModel(authService: authService, authSession: authSession)
    }()

    @AppStorage("selectedTheme") private var selectedTheme: AppTheme = .system

    init() {
        BackgroundScheduleUpdater.shared.registerBackgroundTasks()
        BackgroundScheduleUpdater.shared.scheduleAppRefresh()
    }

    var body: some Scene {
        WindowGroup {
            RootView(
                sessionViewModel: sessionViewModel,
                scheduleViewModel: scheduleViewModel
            )
            .preferredColorScheme(selectedTheme.colorScheme)
            .environmentObject(sessionViewModel)
            .task {
                sessionViewModel.bootstrapAutoLogin()
            }
        }
    }
}
