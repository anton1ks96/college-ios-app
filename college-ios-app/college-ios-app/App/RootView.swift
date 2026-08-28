//
//  RootView.swift
//  college-ios-app
//
//  Created by pc on 18.10.2025.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject private var sessionViewModel: SessionViewModel

    var body: some View {
        Group {
            if sessionViewModel.isBootstrapping {
                SplashView()
            } else {
                MainTabView()
            }
        }
        .animation(.easeInOut(duration: 0.3), value: sessionViewModel.isBootstrapping)
        .alert("Сессия истекла", isPresented: $sessionViewModel.didSessionExpire) {
            Button("Понятно", role: .cancel) {}
        } message: {
            Text("Войдите в аккаунт заново, чтобы видеть пропуски и отметки.")
        }
    }
}
