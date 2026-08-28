//
//  HomeSemester.swift
//  college-ios-app
//

import Foundation

nonisolated enum HomeSemester {

    static func bounds(for date: Date) -> (start: Date, end: Date) {
        let calendar = ScheduleCalendar.calendar
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let isFirstHalf = (1...6).contains(month)

        return (
            start: day(year: year, month: isFirstHalf ? 1 : 9, day: 1),
            end: day(year: year, month: isFirstHalf ? 6 : 12, day: isFirstHalf ? 30 : 31)
        )
    }

    private static func day(year: Int, month: Int, day: Int) -> Date {
        let components = DateComponents(year: year, month: month, day: day)
        return ScheduleCalendar.calendar.date(from: components) ?? .now
    }
}
