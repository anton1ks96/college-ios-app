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
    @State private var showSupportAlert = false
    @State private var showDeveloperSettings = false
    
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
                .onLongPressGesture(minimumDuration: 2) {
                    showDeveloperSettings = true
                }
            }
        }
        .navigationTitle("Настройки")
        .navigationBarTitleDisplayMode(.large)
        .streakToolbar()
        .accountToolbar()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    showSupportAlert = true
                } label: {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.red)
                }
            }
        }
        .navigationDestination(isPresented: $showDeveloperSettings) {
            DeveloperSettingsView()
        }
        .sensoryFeedback(.success, trigger: showDeveloperSettings)
        .alert("Поддержите проект", isPresented: $showSupportAlert) {
            Link("Открыть GitHub", destination: URL(string: "https://github.com/anton1ks96/college-ios-app")!)
            Button("Закрыть", role: .cancel) { }
        } message: {
            Text("В это приложение были вложены силы для вашего комфортного использования. Буду благодарен, если вы поставите ⭐ на GitHub!")
        }
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
