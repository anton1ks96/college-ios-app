//
//  ScheduleDays.swift
//  college-ios-app
//

import Foundation

nonisolated enum ScheduleDays {

    static func week(from weekStart: Date, settings: ScheduleSettings) -> [Date] {
        (0..<7)
            .map { ScheduleCalendar.adding(days: $0, to: weekStart) }
            .filter { !settings.skipWeekends || ScheduleCalendar.weekdayIndex(of: $0) <= 5 }
    }

    static func visible(in days: [Date], selected: Date, settings: ScheduleSettings) -> [Date] {
        let range = settings.view == .week
            ? days
            : Array(days.drop { $0 < selected }.prefix(settings.view.days))
        return range.isEmpty ? Array(days.suffix(settings.view.days)) : range
    }
}
