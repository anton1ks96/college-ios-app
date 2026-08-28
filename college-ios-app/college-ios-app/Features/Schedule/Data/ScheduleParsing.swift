//
//  ScheduleParsing.swift
//  college-ios-app
//

import Foundation

extension ScheduleEventDTO {

    nonisolated func toLesson() -> Lesson? {
        guard let day = ScheduleParsing.date(from: self.day),
              let start = ScheduleParsing.minutes(from: self.start),
              let end = ScheduleParsing.minutes(from: self.end)
        else { return nil }

        return Lesson(
            id: clID.isEmpty ? "\(self.day)-\(self.start)-\(title)" : clID,
            day: day,
            start: start,
            end: end,
            title: title,
            topic: topic,
            room: ScheduleParsing.room(room),
            subgroups: subGroups.map {
                LessonSubgroup(
                    id: $0.groupID,
                    title: $0.title,
                    topic: $0.topic,
                    room: ScheduleParsing.room($0.room)
                )
            }
        )
    }
}

nonisolated enum ScheduleParsing {

    static func date(from value: String) -> Date? {
        dayFormatter.date(from: value.trimmingCharacters(in: .whitespaces))
    }

    static func minutes(from value: String) -> Int? {
        let time = value.trimmingCharacters(in: .whitespaces)
            .split(separator: " ")
            .last
            .map(String.init) ?? ""
        let parts = time.split(separator: ":")
        guard parts.count >= 2,
              let hour = Int(parts[0]), let minute = Int(parts[1]),
              (0...23).contains(hour), (0...59).contains(minute)
        else { return nil }
        return hour * 60 + minute
    }

    static func room(_ value: String) -> String {
        let room = value.trimmingCharacters(in: .whitespaces)
        return room == "—" ? "" : room
    }

    static func requestString(from date: Date) -> String {
        dayFormatter.string(from: date)
    }

    private static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}
