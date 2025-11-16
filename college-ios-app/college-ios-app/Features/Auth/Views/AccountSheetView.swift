//
//  AccountSheetView.swift
//  college-ios-app
//
//  Created by pc on 12.11.2025.
//

import SwiftUI

struct AccountSheetView: View {
    @EnvironmentObject var sessionViewModel: SessionViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showSignOutConfirmation = false
    
    var body: some View {
        NavigationStack {
            Form {
                if let user = sessionViewModel.user {
                    Section("Информация об аккаунте") {
                        AccountRow(
                            systemImage: "person.circle.fill",
                            title: "Логин",
                            value: user.id
                        )
                        
                        AccountRow(
                            systemImage: "person.text.rectangle.fill",
                            title: "ФИО",
                            value: user.username
                        )
                        
                        if let academicGroup = user.academicGroup {
                            AccountRow(
                                systemImage: "graduationcap.fill",
                                title: "Группа",
                                value: academicGroup
                            )
                        }
                        
                        if let profile = user.profile {
                            AccountRow(
                                systemImage: "briefcase.fill",
                                title: "Профиль",
                                value: GroupTypeFormatter.format(profile)
                            )
                        }
                        
                        if let englishGroup = user.englishGroup {
                            AccountRow(
                                systemImage: "globe.europe.africa.fill",
                                title: "Группа Английского",
                                value: englishGroup
                            )
                        }
                        
                        if let subgroup = user.subgroup {
                            AccountRow(
                                systemImage: "number.square.fill",
                                title: "Подгруппа",
                                value: GroupTypeFormatter.formatProfileSubgroup(subgroup)
                            )
                        }
                    }
                    
                    Section {
                        Button(role: .destructive) {
                            showSignOutConfirmation = true
                        } label: {
                            HStack {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                Text("Выйти из аккаунта")
                            }
                        }
                    }
                }
            }
            .scrollBounceBehavior(.basedOnSize)
            .navigationTitle("Профиль")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Выйти из аккаунта?", isPresented: $showSignOutConfirmation) {
                Button("Отмена", role: .cancel) { }
                Button("Выйти", role: .destructive) {
                    sessionViewModel.signOut()
                    dismiss()
                }
            } message: {
                Text("Вы уверены, что хотите выйти из аккаунта?")
            }
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

struct AccountSheetView_Previews: PreviewProvider {
    static var previews: some View {
        let refreshStorage = KeychainTokenStorage()
        let authSession = AuthSession(refreshStorage: refreshStorage)
        
        let decoder = JSONDecoder()
        
        let client = AFHTTPClient(baseURL: AppEnvironment.authBaseURL, decoder: decoder)
        let api = AuthAPI(client: client)
        let authService = AuthService(api: api, session: authSession)
        
        let sessionViewModel = SessionViewModel(authService: authService, authSession: authSession)
        
        let previewUser = User(
            id: "i24s0291",
            username: "i24s0291",
            role: "student",
            academicGroup: "ИТ-307",
            profile: "Программист",
            subgroup: "Подгруппа 1",
            englishGroup: "B1.21"
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
        
        return AccountSheetView()
            .environmentObject(sessionViewModel)
    }
}
