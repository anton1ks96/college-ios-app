//
//  PreviewMocks.swift
//  college-ios-app
//
//  Created by pc on 25.09.2025.
//

import Foundation

class MockScheduleRepository: ScheduleRepositoryProtocol {
    func getSchedule(
        group: String,
        subgroup: String,
        start: Date,
        end: Date
    ) async throws -> [ScheduleEvent] {
        return []
    }
}

class MockUserSettingsRepository: UserSettingsRepositoryProtocol {
    var selectedGroup: String = "ИТ24-11"
    var selectedSubgroup: String = "все"

    func hasStoredSettings() -> Bool {
        return true
    }
}