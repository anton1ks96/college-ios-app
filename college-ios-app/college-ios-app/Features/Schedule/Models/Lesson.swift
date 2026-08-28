//
//  Lesson.swift
//  college-ios-app
//

import Foundation

nonisolated struct LessonSubgroup: Identifiable, Equatable, Sendable {
    let id: String
    let title: String
    let topic: String
    let room: String
}

nonisolated struct Lesson: Identifiable, Equatable, Sendable {
    let id: String
    let day: Date
    let start: Int
    let end: Int
    let title: String
    let topic: String
    let room: String
    let subgroups: [LessonSubgroup]

    init(
        id: String,
        day: Date,
        start: Int,
        end: Int,
        title: String,
        topic: String = "",
        room: String = "",
        subgroups: [LessonSubgroup] = []
    ) {
        self.id = id
        self.day = day
        self.start = start
        self.end = end
        self.title = title
        self.topic = topic
        self.room = room
        self.subgroups = subgroups
    }
}
