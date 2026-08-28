//
//  ScheduleEventParsing.swift
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
