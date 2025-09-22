//
//  SettingsView.swift
//  college-ios-app
//
//  Created by pc on 22.09.2025.
//

import Foundation
import SwiftUI

struct SettingsView: View {
    @ObservedObject var scheduleViewModel: ScheduleViewModel
    
    var body: some View {
        Form {
            Section("Текущие настройки") {
                HStack {
                    Text("Группа")
                    Spacer()
                    Text(scheduleViewModel.selectedGroup)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Подгруппа")
                    Spacer()
                    Text(scheduleViewModel.selectedSubgroup == "*" ? "Все" : scheduleViewModel.selectedSubgroup)
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("Настройки")
        .navigationBarTitleDisplayMode(.large)
    }
}
