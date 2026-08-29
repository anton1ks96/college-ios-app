//
//  LoginViewModel.swift
//  college-ios-app
//
//  Created by pc on 17.10.2025.
//

import Foundation

@Observable
final class LoginViewModel {

    var login: String = "" { didSet { error = nil } }
    var password: String = "" { didSet { error = nil } }

    private(set) var isLoading = false
    private(set) var error: String?
    private(set) var didSignIn = false

    private let authService: AuthService

    init(authService: AuthService = AppDependencies.authService) {
        self.authService = authService
    }

    var canSubmit: Bool {
        !trimmedLogin.isEmpty && !password.isEmpty && !isLoading
    }

    // MARK: - Intents

    func signIn() async {
        guard canSubmit else { return }

        isLoading = true
        error = nil

        do {
            try await authService.signIn(username: trimmedLogin, password: password)
            didSignIn = true
        } catch {
            if !ErrorText.isCancellation(error) {
                self.error = ErrorText.message(for: error) ?? "Не удалось войти"
            }
        }

        isLoading = false
    }

    // MARK: - Helpers

    private var trimmedLogin: String {
        login.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
