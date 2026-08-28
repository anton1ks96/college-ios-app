//
//  ScheduleDTO.swift
//  college-ios-app
//

import Foundation

nonisolated struct ScheduleResponse: Decodable, Sendable {
    let events: [ScheduleEventDTO]

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        events = try container.decodeIfPresent([ScheduleEventDTO].self, forKey: .events) ?? []
    }

    enum CodingKeys: String, CodingKey {
        case events
    }
}

nonisolated struct ScheduleEventDTO: Decodable, Sendable {
    let clID: String
    let day: String
    let start: String
    let end: String
    let title: String
    let topic: String
    let room: String
    let subGroups: [ScheduleSubGroupDTO]

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        clID = try container.decodeIfPresent(String.self, forKey: .clID) ?? ""
        day = try container.decodeIfPresent(String.self, forKey: .day) ?? ""
        start = try container.decodeIfPresent(String.self, forKey: .start) ?? ""
        end = try container.decodeIfPresent(String.self, forKey: .end) ?? ""
        title = try container.decodeIfPresent(String.self, forKey: .title) ?? ""
        topic = try container.decodeIfPresent(String.self, forKey: .topic) ?? ""
        room = try container.decodeIfPresent(String.self, forKey: .room) ?? ""
        subGroups = try container.decodeIfPresent([ScheduleSubGroupDTO].self, forKey: .subGroups) ?? []
    }

    enum CodingKeys: String, CodingKey {
        case clID = "ClID"
        case day = "Day"
        case subGroups = "SubGroup"
        case start, end, title, topic, room
    }
}

nonisolated struct ScheduleSubGroupDTO: Decodable, Sendable {
    let groupID: String
    let title: String
    let topic: String
    let room: String

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        groupID = try container.decodeIfPresent(String.self, forKey: .groupID) ?? ""
        title = try container.decodeIfPresent(String.self, forKey: .title) ?? ""
        topic = try container.decodeIfPresent(String.self, forKey: .topic) ?? ""
        room = try container.decodeIfPresent(String.self, forKey: .room) ?? ""
    }

    enum CodingKeys: String, CodingKey {
        case groupID = "SGrID"
        case title = "STitle"
        case topic = "STopic"
        case room = "SGCaID"
    }
}
