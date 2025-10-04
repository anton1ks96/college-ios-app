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
    
    @StateObject private var viewModel: ScheduleViewModel = {
        let client = AFHTTPClient(baseURL: AppEnvironment.baseURL)
        
        let api = ScheduleAPI(client: client)
        
        let scheduleRepo = ScheduleRepository(api: api)
        
        let settingsRepo = UserSettingsRepository()
        
        return ScheduleViewModel(
            repository: scheduleRepo,
            settingsRepository: settingsRepo
        )
    }()
    
    @AppStorage("selectedTheme") private var selectedTheme: AppTheme = .system
    
    init() {
        BackgroundScheduleUpdater.shared.registerBackgroundTasks()
    }
    
    var body: some Scene {
        WindowGroup {
            MainTabView(scheduleViewModel: viewModel)
                .preferredColorScheme(selectedTheme.colorScheme)
                .onAppear {
                    BackgroundScheduleUpdater.shared.scheduleAppRefresh()
                }
        }
    }
}
