//
//  HomeRepository.swift
//  college-ios-app
//

import Foundation

nonisolated protocol HomeRepositoryProtocol: Sendable {
    func attendance(monday: Date) async throws -> [AttendanceRecord]
    func streak() async throws -> Streak
    func subjects() async throws -> [Subject]
    func scores(subjectID: String, start: Date, end: Date) async throws -> [SubjectLesson]
}

nonisolated final class HomeRepository: HomeRepositoryProtocol {

    private let api: HomeAPIProtocol

    init(api: HomeAPIProtocol) {
        self.api = api
    }

    func attendance(monday: Date) async throws -> [AttendanceRecord] {
        let end = ScheduleCalendar.adding(days: 6, to: monday)
        return HomeParsing.records(from: try await api.attendance(start: monday, end: end))
    }

    func streak() async throws -> Streak {
        HomeParsing.streak(from: try await api.streak())
    }

    func subjects() async throws -> [Subject] {
        HomeParsing.subjects(from: try await api.subjects())
    }

    func scores(subjectID: String, start: Date, end: Date) async throws -> [SubjectLesson] {
        let response = try await api.scores(subjectID: subjectID, start: start, end: end)
        return HomeParsing.lessons(from: response)
    }
}
