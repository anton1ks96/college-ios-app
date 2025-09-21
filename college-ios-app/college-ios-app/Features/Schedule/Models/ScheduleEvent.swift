//
//  ScheduleEvent.swift
//  college-ios-app
//
//  Created by pc on 21.09.2025.
//

import Foundation

struct ScheduleEvent: Decodable, Identifiable {
    let id = UUID()
    let clID: String
    let type: String?
    let day: String
    let group: String
    let topic: String
    let start: String
    let end: String
    let room: String
    let color: String
    let title: String
    let subGroups: [ScheduleSubGroup]?

    enum CodingKeys: String, CodingKey {
        case clID = "ClID"
        case type
        case day = "Day"
        case group, topic, start, end, room, color, title
        case subGroups = "SubGroup"
    }
}
