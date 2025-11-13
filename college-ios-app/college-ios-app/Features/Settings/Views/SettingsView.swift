//
//  SettingsView.swift
//  college-ios-app
//
//  Created by pc on 22.09.2025.
//

import Foundation
import SwiftUI

struct SettingsView: View {
    @AppStorage("selectedTheme") private var selectedTheme: AppTheme = .system
    
    var body: some View {
        Form {
            Section("Общие настройки") {
                NavigationLink {
                    AppThemeView()
                } label: {
                    HStack {
                        Image(systemName: selectedTheme.iconName)
                        Text("Тема")
                        Spacer()
                        Text(selectedTheme.rawValue)
                            .foregroundColor(.secondary)
                    }
                }
                
                NavigationLink {
                    ScheduleSettings()
                } label : {
                    HStack {
                        Image(systemName: "calendar")
                        Text("Расписание")
                    }
                }
            }
            
            Section("Информация") {
                NavigationLink {
                    AboutView()
                } label: {
                    HStack {
                        Image(systemName: "info.circle")
                        Text("О приложении")
                    }
                }
            }
        }
        .navigationTitle("Настройки")
        .navigationBarTitleDisplayMode(.large)
        .accountToolbar()
    }
}

#Preview {
    let refreshStorage = KeychainTokenStorage()
    let authSession = AuthSession(refreshStorage: refreshStorage)
    let decoder = JSONDecoder()
    let client = AFHTTPClient(baseURL: AppEnvironment.authBaseURL, decoder: decoder)
    let api = AuthAPI(client: client)
    let authService = AuthService(api: api, session: authSession)
    let sessionViewModel = SessionViewModel(authService: authService, authSession: authSession)
    
    return NavigationStack {
        SettingsView()
            .environmentObject(sessionViewModel)
    }
}
