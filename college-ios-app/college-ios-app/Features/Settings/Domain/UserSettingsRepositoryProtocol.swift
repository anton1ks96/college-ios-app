//
//  UserSettingsRepositoryProtocol.swift
//  college-ios-app
//
//  Created by pc on 22.09.2025.
//

import Foundation

enum DefaultScheduleView: String, CaseIterable, Identifiable {
    case today = "Сегодня"
    case threeDays = "3 дня"
    case week = "Неделя"
    
    var id: String { self.rawValue }
    
    var daysFromToday: Int {
        switch self {
        case .today: return 0
        case .threeDays: return 2
        case .week: return 6
        }
    }
    
    var iconName: String {
        switch self {
        case .today: return "calendar.day.timeline.left"
        case .threeDays: return "calendar"
        case .week: return "calendar.badge.clock"
        }
    }
}

protocol UserSettingsRepositoryProtocol {
    var selectedGroup: String { get set }
    
    var selectedSubgroup: String { get set }
    
    var selectedEnglishGroup: String { get set }
    
    var defaultScheduleView: DefaultScheduleView { get set }
    
    var skipWeekends: Bool { get set }
    
    func hasStoredSettings() -> Bool
}
