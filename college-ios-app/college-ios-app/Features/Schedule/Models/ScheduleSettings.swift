//
//  ScheduleSettings.swift
//  college-ios-app
//

import Foundation

nonisolated enum ScheduleView: String, CaseIterable, Identifiable, Sendable {
    case today
    case threeDays
    case week

    var id: String { rawValue }

    var title: String {
        switch self {
        case .today: return "Сегодня"
        case .threeDays: return "3 дня"
        case .week: return "Неделя"
        }
    }

    var days: Int {
        switch self {
        case .today: return 1
        case .threeDays: return 3
        case .week: return 7
        }
    }
}

nonisolated struct ScheduleSettings: Equatable, Sendable {
    var view: ScheduleView = .threeDays
    var skipWeekends: Bool = false
}
