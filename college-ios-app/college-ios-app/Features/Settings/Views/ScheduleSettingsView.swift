//
//  ScheduleSettingsView.swift
//  college-ios-app
//
//  Created by pc on 17.10.2025.
//

import Foundation
import SwiftUI

extension Notification.Name {
    static let scheduleSettingsDidChange = Notification.Name("scheduleSettingsDidChange")
}

struct ScheduleSettings: View {
    private let settingsRepository = UserSettingsRepository()
    @State private var defaultScheduleView: DefaultScheduleView
    @State private var skipWeekends: Bool

    init() {
        let repo = UserSettingsRepository()
        _defaultScheduleView = State(initialValue: repo.defaultScheduleView)
        _skipWeekends = State(initialValue: repo.skipWeekends)
    }

    var body: some View {
        Form {
            Section {
                ForEach(DefaultScheduleView.allCases) { view in
                    Button {
                        defaultScheduleView = view
                        settingsRepository.defaultScheduleView = view
                        NotificationCenter.default.post(name: .scheduleSettingsDidChange, object: nil)
                    } label: {
                        HStack {
                            Image(systemName: view.iconName)
                                .foregroundColor(Color("AccentColor"))
                            Text(view.rawValue)
                            Spacer()
                            if defaultScheduleView == view {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.accentColor)
                            }
                        }
                    }
                    .foregroundColor(.primary)
                }
            } header: {
                Text("Отображение по умолчанию")
            } footer: {
                Text("Выберите период, который будет отображаться при открытии расписания")
            }

            Section {
                Toggle(isOn: Binding(
                    get: { skipWeekends },
                    set: { newValue in
                        skipWeekends = newValue
                        settingsRepository.skipWeekends = newValue
                        NotificationCenter.default.post(name: .scheduleSettingsDidChange, object: nil)
                    }
                )) {
                    HStack {
                        Image(systemName: "calendar.badge.minus")
                            .frame(width: 24)
                            .foregroundColor(.orange)
                        Text("Пропускать выходные")
                    }
                }
            } footer: {
                Text("При включении выходные дни не будут отображаться в расписании")
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Настройка расписания").font(.headline)
            }
        }
    }
}

#Preview {
    NavigationStack {
        ScheduleSettings()
    }
}
