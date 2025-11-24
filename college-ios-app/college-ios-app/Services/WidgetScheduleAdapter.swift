//
//  WidgetScheduleAdapter.swift
//  college-ios-app
//
//  Created by pc on 01.10.2025.
//

import Foundation

struct WidgetScheduleAdapter {

    // MARK: - Dependencies
    private let bridge: WidgetScheduleBridge
    private let settingsRepository: UserSettingsRepositoryProtocol

    // MARK: - Init
    init(
        bridge: WidgetScheduleBridge = .shared,
        settingsRepository: UserSettingsRepositoryProtocol = UserSettingsRepository()
    ) {
        self.bridge = bridge
        self.settingsRepository = settingsRepository
    }

    // MARK: - Public Methods

    func loadTodayEvents() -> [ScheduleEvent] {
        guard let allEvents = bridge.loadSchedule() else {
            return []
        }

        let today = DateFormatters.request.string(from: Date())
        return allEvents.filter { $0.day == today }
    }

    func loadTomorrowEvents() -> [ScheduleEvent] {
        guard let allEvents = bridge.loadSchedule() else {
            return []
        }

        let calendar = Calendar.current
        guard let tomorrow = calendar.date(byAdding: .day, value: 1, to: Date()) else {
            return []
        }

        let tomorrowString = DateFormatters.request.string(from: tomorrow)
        return allEvents.filter { $0.day == tomorrowString }
    }

    func loadAllEvents() -> [ScheduleEvent] {
        return bridge.loadSchedule() ?? []
    }

    func getCurrentEvent() -> ScheduleEvent? {
        let todayEvents = loadTodayEvents()
        let now = Date()
        let timeFormatter = DateFormatters.uiTime

        return todayEvents.first { event in
            guard let startTime = timeFormatter.date(from: event.start),
                  let endTime = timeFormatter.date(from: event.end) else {
                return false
            }

            let calendar = Calendar.current
            let startDateTime = calendar.date(
                bySettingHour: calendar.component(.hour, from: startTime),
                minute: calendar.component(.minute, from: startTime),
                second: 0,
                of: now
            )!
            let endDateTime = calendar.date(
                bySettingHour: calendar.component(.hour, from: endTime),
                minute: calendar.component(.minute, from: endTime),
                second: 0,
                of: now
            )!

            return now >= startDateTime && now <= endDateTime
        }
    }

    func getNextEvent() -> ScheduleEvent? {
        let todayEvents = loadTodayEvents()
        let now = Date()
        let timeFormatter = DateFormatters.uiTime

        return todayEvents.first { event in
            guard let startTime = timeFormatter.date(from: event.start) else {
                return false
            }

            let calendar = Calendar.current
            let startDateTime = calendar.date(
                bySettingHour: calendar.component(.hour, from: startTime),
                minute: calendar.component(.minute, from: startTime),
                second: 0,
                of: now
            )!

            return now < startDateTime
        }
    }

    func hasSettings() -> Bool {
        return settingsRepository.hasStoredSettings()
    }

    func getSelectedGroup() -> String {
        return settingsRepository.selectedGroup
    }

    func getSelectedSubgroup() -> String {
        return settingsRepository.selectedSubgroup
    }

    func getSelectedEnglishGroup() -> String {
        return settingsRepository.selectedEnglishGroup
    }

    func hasValidSettings() -> Bool {
        guard settingsRepository.hasStoredSettings() else {
            return false
        }

        let group = settingsRepository.selectedGroup
        let subgroup = settingsRepository.selectedSubgroup
        let englishGroup = settingsRepository.selectedEnglishGroup

        let hasGroup = !group.isEmpty
        let hasSubgroup = subgroup != "*"
        let hasEnglishGroup = englishGroup != "*"

        return hasGroup && hasSubgroup && hasEnglishGroup
    }

    func hasCachedSchedule() -> Bool {
        return bridge.loadSchedule() != nil
    }

    func getLastUpdateDate() -> Date? {
        return bridge.lastUpdateDate()
    }
}
