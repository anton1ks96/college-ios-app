//
//  AppThemeView.swift
//  college-ios-app
//
//  Created by pc on 25.09.2025.
//

import Foundation
import SwiftUI

enum AppTheme: String, CaseIterable, Identifiable {
    case system = "Системная"
    case light = "Светлая"
    case dark = "Тёмная"
    
    var id: String { self.rawValue }
    
    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
    
    var iconName: String {
        switch self {
        case .system: return "gearshape"
        case .light: return "sun.max"
        case .dark: return "moon.fill"
        }
    }
}


struct AppThemeView: View {
    @AppStorage("selectedTheme") private var selectedTheme: AppTheme = .system

    var body: some View {
        Form {
            Section() {
                ForEach(AppTheme.allCases) { theme in
                    Button {
                        selectedTheme = theme
                    } label: {
                        HStack {
                            Text(theme.rawValue)
                            Spacer()
                            if selectedTheme == theme {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.accentColor)
                            }
                        }
                    }
                    .foregroundColor(.primary)
                }
            }
        }
        .navigationTitle("Выбор темы оформления")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    AppThemeView()
}
