//
//  PreviewMocks.swift
//  college-ios-app
//
//  Created by pc on 25.09.2025.
//

import Foundation

// MARK: - Schedule Repository Mock
class MockScheduleRepository: ScheduleRepositoryProtocol {
    enum Scenario {
        case success
        case error
        case empty
    }

    let scenario: Scenario

    init(scenario: Scenario = .empty) {
        self.scenario = scenario
    }

    func getSchedule(
        group: String,
        subgroup: String,
        englishGroup: String,
        start: Date,
        end: Date
    ) async throws -> [ScheduleEvent] {
        switch scenario {
        case .success:
            return PreviewMocks.sampleEvents
        case .error:
            throw NSError(domain: "PreviewError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Не удалось загрузить расписание"])
        case .empty:
            return []
        }
    }
}

// MARK: - User Settings Repository Mock
class MockUserSettingsRepository: UserSettingsRepositoryProtocol {
    var selectedGroup: String = "ИТ-307"
    var selectedSubgroup: String = "*"
    var selectedEnglishGroup: String = "*"
    var defaultScheduleView: DefaultScheduleView = .threeDays
    var skipWeekends: Bool = false

    func hasStoredSettings() -> Bool {
        return true
    }
}

// MARK: - Preview Mocks
enum PreviewMocks {
    @MainActor
    static var scheduleViewModelWithData: ScheduleViewModel {
        let viewModel = ScheduleViewModel(
            repository: MockScheduleRepository(scenario: .success),
            settingsRepository: MockUserSettingsRepository()
        )
        viewModel.events = sampleEvents
        return viewModel
    }

    @MainActor
    static var scheduleViewModelLoading: ScheduleViewModel {
        let viewModel = ScheduleViewModel(
            repository: MockScheduleRepository(scenario: .success),
            settingsRepository: MockUserSettingsRepository()
        )
        viewModel.isLoading = true
        return viewModel
    }

    @MainActor
    static var scheduleViewModelError: ScheduleViewModel {
        let viewModel = ScheduleViewModel(
            repository: MockScheduleRepository(scenario: .error),
            settingsRepository: MockUserSettingsRepository()
        )
        viewModel.errorMessage = "Не удалось загрузить расписание"
        return viewModel
    }

    @MainActor
    static var scheduleViewModelEmpty: ScheduleViewModel {
        ScheduleViewModel(
            repository: MockScheduleRepository(scenario: .empty),
            settingsRepository: MockUserSettingsRepository()
        )
    }

    static var sampleEvents: [ScheduleEvent] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let today = formatter.string(from: Date())

        return [
            ScheduleEvent(
                clID: "1",
                type: "ЛК",
                day: today,
                group: "ИТ-307",
                topic: "Основы программирования",
                start: "09:00",
                end: "10:30",
                room: "404",
                color: "#FF6B6B",
                title: "Программирование на Python",
                subGroups: nil
            ),
            ScheduleEvent(
                clID: "2",
                type: "ПР",
                day: today,
                group: "ИТ-307",
                topic: "Веб-разработка",
                start: "10:45",
                end: "12:15",
                room: "301",
                color: "#4ECDC4",
                title: "Frontend разработка",
                subGroups: nil
            ),
            ScheduleEvent(
                clID: "3",
                type: "ЛК",
                day: today,
                group: "ИТ-307",
                topic: "Базы данных",
                start: "13:00",
                end: "14:30",
                room: "215",
                color: "#95E1D3",
                title: "SQL и NoSQL",
                subGroups: nil
            )
        ]
    }
}