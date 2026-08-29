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
    @Published var didSessionExpire: Bool = false

    let authService: AuthService
    private let authSession: AuthSession
    private var eventsTask: Task<Void, Never>?

    init(authService: AuthService, authSession: AuthSession) {
        self.authService = authService
        self.authSession = authSession
        observeAuthEvents()
    }

    deinit {
        eventsTask?.cancel()
    }

    private func observeAuthEvents() {
        eventsTask = Task { [weak self, events = authService.events] in
            for await event in events {
                guard let self else { return }
                await self.syncFromSession()
                if case .signedOut(.sessionExpired) = event {
                    self.didSessionExpire = true
                }
            }
        }
    }
    
    func bootstrapAutoLogin() {
        Task {
            isBootstrapping = true
            
            await authService.bootstrapAutoLogin()
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

