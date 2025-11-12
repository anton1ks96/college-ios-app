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
                        
                        if let academicGroup = user.academicGroup {
                            AccountRow(
                                systemImage: "graduationcap.fill",
                                title: "Группа",
                                value: academicGroup
                            )
                        }
                        
                        if let profile = user.profile {
                            AccountRow(
                                systemImage: "person.fill",
                                title: "Профиль",
                                value: profile
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
            .navigationTitle("Профиль")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Готово") {
                        dismiss()
                    }
                }
            }
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
        
        return AccountSheetView()
            .environmentObject(sessionViewModel)
    }
}
