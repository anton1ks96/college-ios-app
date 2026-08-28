//
//  SettingsScreen.swift
//  college-ios-app
//

import SwiftUI

struct SettingsScreen: View {
    @EnvironmentObject private var sessionViewModel: SessionViewModel

    let onLogin: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
        }
        .navigationTitle("Настройки")
    }
}

#Preview {
    NavigationStack { SettingsScreen(onLogin: {}) }
        .environmentObject(PreviewMocks.sessionViewModel())
}
