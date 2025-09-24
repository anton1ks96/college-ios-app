//
//  MainTabView.swift
//  college-ios-app
//
//  Created by pc on 22.09.2025.
//

import SwiftUI

struct MainTabView: View {
    @ObservedObject var scheduleViewModel: ScheduleViewModel
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                ScheduleView(viewModel: scheduleViewModel)
            }
            .tabItem {
                Label("Расписание", systemImage: "calendar")
            }
            .tag(0)

            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("Настройки", systemImage: "gear")
            }
            .tag(1)
        }
    }
}
