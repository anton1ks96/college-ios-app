//
//  MainTabView.swift
//  college-ios-app
//
//  Created by pc on 22.09.2025.
//

import SwiftUI

struct MainTabView: View {
    @ObservedObject var scheduleViewModel: ScheduleViewModel
    @ObservedObject var sessionViewModel: SessionViewModel
    @ObservedObject var attendanceViewModel: AttendanceViewModel
    @ObservedObject var performanceViewModel: PerformanceViewModel
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

            if sessionViewModel.isAuthenticated {
                NavigationStack {
                    AttendanceView(viewModel: attendanceViewModel)
                }
                .tabItem {
                    Label("Пропуски", systemImage: "checkmark.circle")
                }
                .tag(1)
            }
            
            if sessionViewModel.isAuthenticated {
                NavigationStack {
                    PerformanceView(viewModel: performanceViewModel)
                }
                .tabItem {
                    Label("Отметки", systemImage: "chart.bar.xaxis")
                }
                .tag(2)
            }
            
            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("Настройки", systemImage: "gear")
            }
            .tag(3)
        }
        .checkForAppUpdates()
    }
}
