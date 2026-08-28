//
//  MainTabView.swift
//  college-ios-app
//
//  Created by pc on 22.09.2025.
//

import SwiftUI

enum Tab: String {
    case schedule
    case home
    case settings
}

struct MainTabView: View {
    @EnvironmentObject private var sessionViewModel: SessionViewModel
    @Environment(\.colorScheme) private var colorScheme
    @SceneStorage("selectedTab") private var selectedTab: Tab = .schedule
    @State private var homeViewModel = HomeViewModel()
    @State private var isLoginPresented = false

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                ScheduleScreen()
            }
            .tabItem {
                Label("Расписание", systemImage: "calendar")
            }
            .tag(Tab.schedule)

            NavigationStack {
                HomeScreen(
                    viewModel: homeViewModel,
                    onLogin: { isLoginPresented = true }
                )
            }
            .tabItem {
                Label("Главная", systemImage: "house")
            }
            .tag(Tab.home)

            NavigationStack {
                SettingsScreen()
            }
            .tabItem {
                Label("Настройки", systemImage: "gearshape")
            }
            .tag(Tab.settings)
        }
        .environment(\.colors, AppColors.of(colorScheme))
        .onChange(of: session, initial: true) { _, updated in
            homeViewModel.sync(user: updated.user, isBootstrapping: updated.isBootstrapping)
        }
        .fullScreenCover(isPresented: $isLoginPresented) {
            LoginScreen(onClose: { isLoginPresented = false })
                .preferredColorScheme(.dark)
        }
    }

    private var session: HomeSession {
        HomeSession(user: sessionViewModel.user, isBootstrapping: sessionViewModel.isBootstrapping)
    }
}
