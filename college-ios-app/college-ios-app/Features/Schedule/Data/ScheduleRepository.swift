//
//  ScheduleRepository.swift
//  college-ios-app
//
//  Created by pc on 21.09.2025.
//

import Foundation

protocol ScheduleRepositoryProtocol {
    func getSchedule(
        group: String,
        subgroup: String,
        start: Date,
        end: Date
    ) async throws -> [ScheduleEvent]
}

final class ScheduleRepository: ScheduleRepositoryProtocol {
    private let api: ScheduleAPIProtocol

    init(api: ScheduleAPIProtocol) {
        self.api = api
    }

    func getSchedule(
        group: String,
        subgroup: String,
        start: Date,
        end: Date
    ) async throws -> [ScheduleEvent] {
        let response = try await api.fetchSchedule(
            group: group,
            subgroup: subgroup,
            start: start,
            end: end
        )

        var events = response.events

        events.sort {
            if $0.day != $1.day {
                return $0.day < $1.day
            }
            return $0.start < $1.start
        }

        return events
    }
}
