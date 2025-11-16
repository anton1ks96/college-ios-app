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

    var body: some View {
        Group {
            if sessionViewModel.isBootstrapping {
                SplashView()
            } else {
                MainTabView(
                    scheduleViewModel: scheduleViewModel,
                    sessionViewModel: sessionViewModel,
                    attendanceViewModel: attendanceViewModel
                )
            }
        }
        .animation(.easeInOut(duration: 0.3), value: sessionViewModel.isBootstrapping)
    }
}
