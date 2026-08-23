//
//  RootView.swift
//  college-ios-app
//
//  Created by pc on 18.10.2025.
//

import SwiftUI

struct RootView: View {
    @ObservedObject var sessionViewModel: SessionViewModel
    @ObservedObject var scheduleViewModel: ScheduleViewModel
    @ObservedObject var attendanceViewModel: AttendanceViewModel
    @ObservedObject var performanceViewModel: PerformanceViewModel
    @ObservedObject var streakViewModel: StreakViewModel
    
    var body: some View {
        Group {
            if sessionViewModel.isBootstrapping {
                SplashView()
            } else {
                MainTabView(
                    scheduleViewModel: scheduleViewModel,
                    sessionViewModel: sessionViewModel,
                    attendanceViewModel: attendanceViewModel,
                    performanceViewModel: performanceViewModel
                )
            }
        }
        .animation(.easeInOut(duration: 0.3), value: sessionViewModel.isBootstrapping)
        .onChange(of: sessionViewModel.isAuthenticated) { _, isAuthenticated in
            if isAuthenticated {
                Task {
                    await streakViewModel.loadStreak()
                }
            } else {
                streakViewModel.clear()
                attendanceViewModel.clear()
                performanceViewModel.clear()
            }
        }
        .task {
            if sessionViewModel.isAuthenticated {
                await streakViewModel.loadStreak()
            }
        }
        .alert("Сессия истекла", isPresented: $sessionViewModel.didSessionExpire) {
            Button("Понятно", role: .cancel) {}
        } message: {
            Text("Войдите в аккаунт заново, чтобы видеть пропуски и отметки.")
        }
    }
}
