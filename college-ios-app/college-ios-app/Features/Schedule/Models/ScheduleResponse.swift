//
//  ScheduleResponse.swift
//  college-ios-app
//
//  Created by pc on 21.09.2025.
//

nonisolated struct ScheduleResponse: Decodable {
    let events: [ScheduleEvent]
}
