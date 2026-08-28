//
//  ScheduleFormat.swift
//  college-ios-app
//

import Foundation

nonisolated enum ScheduleFormat {

    static func time(_ minutes: Int) -> String {
        String(format: "%d:%02d", minutes / 60, minutes % 60)
    }

    static func weekdayShort(_ date: Date) -> String {
        shortWeekdays[ScheduleCalendar.weekdayIndex(of: date) - 1]
    }

    static func dayMonth(_ date: Date) -> String {
        let parts = ScheduleCalendar.calendar.dateComponents([.day, .month], from: date)
        return "\(parts.day ?? 0) \(genitiveMonths[(parts.month ?? 1) - 1])"
    }

    static func dayTitle(_ date: Date) -> String {
        "\(fullWeekdays[ScheduleCalendar.weekdayIndex(of: date) - 1]), \(dayMonth(date))"
    }

    static func dateRange(from: Date, to: Date) -> String {
        let calendar = ScheduleCalendar.calendar
        let sameMonth = calendar.component(.month, from: from) == calendar.component(.month, from: to)
        let start = sameMonth ? "\(calendar.component(.day, from: from))" : dayMonth(from)
        return "\(start) – \(dayMonth(to))"
    }

    static func lessonsCount(_ count: Int) -> String {
        let word: String
        switch (count % 100, count % 10) {
        case (11...14, _): word = "пар"
        case (_, 1): word = "пара"
        case (_, 2...4): word = "пары"
        default: word = "пар"
        }
        return "\(count) \(word)"
    }

    private static let genitiveMonths = [
        "января", "февраля", "марта", "апреля", "мая", "июня",
        "июля", "августа", "сентября", "октября", "ноября", "декабря",
    ]

    private static let fullWeekdays = [
        "Понедельник", "Вторник", "Среда", "Четверг", "Пятница", "Суббота", "Воскресенье",
    ]

    private static let shortWeekdays = ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс"]
}
