//
//  LoginViewModel.swift
//  college-ios-app
//
//  Created by pc on 17.10.2025.
//

import Foundation
import SwiftUI
internal import Combine

final class LoginViewModel: ObservableObject {
    @Published var login: String = ""
    @Published var password: String = ""
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var isLoggedIn: Bool = false
    
    private let authService: AuthService
    
    init (authService: AuthService) {
        self.authService = authService
    }
    
    func signIn() async {
        errorMessage = nil
        guard !login.isEmpty, !password.isEmpty else {
            errorMessage = "Введите логин и пароль"
            return
        }
        
        isLoading = true
        do {
            try await authService.signIn(username: login, password: password)
            isLoggedIn = true
        } catch {
            if let apiError = error as? APIError {
                errorMessage = apiError.localizedDescription
            } else {
                errorMessage = error.localizedDescription
            }
        }
        isLoading = false
    }
}
