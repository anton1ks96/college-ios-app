//
//  SessionViewModel.swift
//  college-ios-app
//
//  Created by pc on 17.10.2025.
//

import Foundation
import SwiftUI
internal import Combine

@MainActor
final class SessionViewModel: ObservableObject {
    
    @Published private(set) var user: User?
    @Published private(set) var isAuthenticated: Bool = false
    @Published var isBootstrapping: Bool = true
    @Published var lastError: String?
    
    let authService: AuthService
    private let authSession: AuthSession
    
    init(authService: AuthService, authSession: AuthSession) {
        self.authService = authService
        self.authSession = authSession
    }
    
    func bootstrapAutoLogin() {
        Task {
            isBootstrapping = true
            
            await authService.bootstrapAutoLogin(loadUser: true)
            await syncFromSession()
            
            isBootstrapping = false
        }
    }
    
    func syncFromSession() async {
        let currentUser = await authSession.currentUser
        let access = await authSession.accessToken
        self.user = currentUser
        self.isAuthenticated = (currentUser != nil) && (access != nil)
    }
    
    func signOut() {
        Task {
            await authService.signOut()
            await syncFromSession()
        }
    }
}

