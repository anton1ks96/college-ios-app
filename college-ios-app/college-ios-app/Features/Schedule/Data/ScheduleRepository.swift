//
//  ScheduleRepository.swift
//  college-ios-app
//

import Foundation

nonisolated protocol ScheduleRepositoryProtocol: Sendable {
    func weekSchedule(monday: Date, selection: Selection) async throws -> [Lesson]
    func classDetails(id: String) async throws -> [DetailRow]
}

nonisolated final class ScheduleRepository: ScheduleRepositoryProtocol {

    private let api: ScheduleAPIProtocol

    init(api: ScheduleAPIProtocol) {
        self.api = api
    }

    func weekSchedule(monday: Date, selection: Selection) async throws -> [Lesson] {
        let end = ScheduleCalendar.adding(days: 6, to: monday)
        let response = try await api.schedule(selection: selection, start: monday, end: end)
        return response.events.compactMap { $0.toLesson() }
    }

    func classDetails(id: String) async throws -> [DetailRow] {
        try await api.classDetails(id: id).detailRows()
    }
}
