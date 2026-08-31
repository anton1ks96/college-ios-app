//
//  LessonProgress.swift
//  college-ios-app
//

import Foundation

nonisolated enum LessonProgress {

    static func secondsLeft(of lesson: Lesson, at date: Date) -> Int {
        let left = end(of: lesson).timeIntervalSince(date)
        return max(Int(left.rounded(.up)), 0)
    }

    static func fraction(of lesson: Lesson, at date: Date) -> Double {
        let start = start(of: lesson)
        let total = end(of: lesson).timeIntervalSince(start)
        guard total > 0 else { return 1 }
        return min(max(date.timeIntervalSince(start) / total, 0), 1)
    }

    private static func start(of lesson: Lesson) -> Date {
        ScheduleCalendar.date(lesson.day, atMinutes: lesson.start)
    }

    private static func end(of lesson: Lesson) -> Date {
        ScheduleCalendar.date(lesson.day, atMinutes: lesson.end)
    }
}
