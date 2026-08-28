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
    @Environment(\.colorScheme) private var colorScheme
    @SceneStorage("selectedTab") private var selectedTab: Tab = .schedule
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
                HomeScreen(onLogin: { isLoginPresented = true })
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
        .fullScreenCover(isPresented: $isLoginPresented) {
            LoginScreen(onClose: { isLoginPresented = false })
                .preferredColorScheme(.dark)
        }
    }
}
