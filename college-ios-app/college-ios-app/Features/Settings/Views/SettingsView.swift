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



struct AccountRow: View {
    let systemImage: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: systemImage)
                .font(.system(size: 20))
                .foregroundColor(.accentColor)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.body)
            }
        }
        .padding(.vertical, 4)
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
