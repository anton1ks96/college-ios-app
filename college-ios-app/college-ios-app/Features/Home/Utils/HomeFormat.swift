//
//  HomeFormat.swift
//  college-ios-app
//

import Foundation

nonisolated enum HomeFormat {

    static func daysInRow(_ count: Int) -> String {
        count == 0 ? "Стрик прервался" : "\(ScheduleFormat.daysCount(count)) подряд"
    }

    static func status(rate: Double) -> String {
        switch rate {
        case 90...: "Ходишь почти без пропусков — так держать"
        case 75..<90: "Крепкая посещаемость, всё под контролем"
        case 50..<75: "Бывает по-разному — можно лучше"
        default: "Пропусков много, пора возвращаться"
        }
    }

    static func average(_ value: Double) -> String {
        value.formatted(.number.precision(.fractionLength(1)).locale(ScheduleCalendar.locale))
    }

    static func date(_ date: Date) -> String {
        let parts = ScheduleCalendar.calendar.dateComponents([.day, .month, .year], from: date)
        return String(format: "%d.%02d.%d", parts.day ?? 0, parts.month ?? 0, parts.year ?? 0)
    }

    static func attended(present: Int, total: Int) -> String {
        "Был на \(present) из \(ScheduleFormat.lessonsCount(total))"
    }
}
