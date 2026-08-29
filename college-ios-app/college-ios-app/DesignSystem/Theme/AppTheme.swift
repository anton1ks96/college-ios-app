//
//  AppTheme.swift
//  college-ios-app
//

import SwiftUI

enum AppTheme: String, CaseIterable, Identifiable {
    case system = "Системная"
    case light = "Светлая"
    case dark = "Тёмная"

    static let storageKey = "selectedTheme"

    var id: String { rawValue }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}
