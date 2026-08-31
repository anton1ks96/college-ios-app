//
//  ScheduleParsing.swift
//  college-ios-app
//

import Foundation

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

    static func timestamp(from value: String) -> Date? {
        try? Date(value.trimmingCharacters(in: .whitespaces), strategy: .iso8601)
    }

    private static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}
