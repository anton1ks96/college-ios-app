//
//  SettingsView.swift
//  college-ios-app
//
//  Created by pc on 22.09.2025.
//

import Foundation
import SwiftUI

struct SettingsView: View {
    @AppStorage("selectedTheme") private var selectedTheme: AppTheme = .system

    var body: some View {
        Form {
            Section("Общие настройки") {
                NavigationLink {
                    AppThemeView()
                } label: {
                    HStack {
                        Image(systemName: selectedTheme.iconName)
                        Text("Тема")
                        Spacer()
                        Text(selectedTheme.rawValue)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Section("Информация") {
                NavigationLink {
                    AboutView()
                } label: {
                    HStack {
                        Image(systemName: "info.circle")
                        Text("О приложении")
                    }
                }
            }
        }
        .navigationTitle("Настройки")
        .navigationBarTitleDisplayMode(.large)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        return NavigationView {
            SettingsView()
        }
    }
}
