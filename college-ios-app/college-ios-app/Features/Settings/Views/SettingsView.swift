//
//  SettingsView.swift
//  college-ios-app
//
//  Created by pc on 22.09.2025.
//

import Foundation
import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var sessionViewModel: SessionViewModel
    @AppStorage("selectedTheme") private var selectedTheme: AppTheme = .system
    @State private var showLogin = false
    
    var body: some View {
        VStack(spacing: 0) {
            Form {
                // MARK: - User Info Section
                if sessionViewModel.isAuthenticated, let user = sessionViewModel.user {
                    Section("Аккаунт") {
                        AccountRow(systemImage: "person.circle.fill",
                                   title: "Логин",
                                   value: user.id)
                        
                        if let academicGroup = user.academicGroup {
                            AccountRow(systemImage: "graduationcap.fill",
                                       title: "Группа",
                                       value: academicGroup)
                        }
                        
                        if let profile = user.profile {
                            AccountRow(systemImage: "person.fill",
                                       title: "Профиль",
                                       value: profile)
                        }
                    }
                }
                
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
            
            // MARK: - Auth Button
            VStack {
                Button {
                    if sessionViewModel.isAuthenticated {
                        sessionViewModel.signOut()
                    } else {
                        showLogin = true
                    }
                } label: {
                    Text(sessionViewModel.isAuthenticated ? "Выйти" : "Войти в аккаунт")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(sessionViewModel.isAuthenticated ? Color.red : Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .background(Color(.systemGroupedBackground))
        }
        .navigationTitle("Настройки")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showLogin) {
            LoginView()
        }
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

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        let refreshStorage = KeychainTokenStorage()
        let authSession = AuthSession(refreshStorage: refreshStorage)
        
        let decoder = JSONDecoder()
        
        let client = AFHTTPClient(baseURL: AppEnvironment.baseURL, decoder: decoder)
        let api = AuthAPI(client: client)
        let authService = AuthService(api: api, session: authSession)
        
        let sessionViewModel = SessionViewModel(authService: authService, authSession: authSession)
        
        let previewUser = User(
            id: "i24s0291",
            username: "i24s0291",
            role: "student",
            academicGroup: "ИТ-307",
            profile: "Программист"
        )
        let signIn = SignInResponse(
            accessToken: "preview_access_token",
            refreshToken: "preview_refresh_token",
            accessExpiresIn: 3600,
            refreshExpiresIn: 60 * 60 * 24 * 30,
            user: previewUser
        )
        
        Task {
            try? await authSession.setLoggedIn(signIn: signIn)
            await sessionViewModel.syncFromSession()
        }
        
        return NavigationView {
            SettingsView()
                .environmentObject(sessionViewModel)
        }
    }
}
