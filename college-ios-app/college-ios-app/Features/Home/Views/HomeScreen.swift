//
//  HomeScreen.swift
//  college-ios-app
//

import SwiftUI

struct HomeScreen: View {
    @EnvironmentObject private var sessionViewModel: SessionViewModel

    let onLogin: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
        }
        .navigationTitle("Главная")
    }
}

#Preview {
    NavigationStack { HomeScreen(onLogin: {}) }
        .environmentObject(PreviewMocks.sessionViewModel())
}
