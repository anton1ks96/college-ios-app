//
//  StreakToolbarModifier.swift
//  college-ios-app
//

import SwiftUI

struct StreakToolbarModifier: ViewModifier {
    @EnvironmentObject var sessionViewModel: SessionViewModel
    @EnvironmentObject var streakViewModel: StreakViewModel
    @State private var showStreakSheet = false

    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if sessionViewModel.isAuthenticated {
                        Button {
                            showStreakSheet = true
                        } label: {
                            StreakBadgeView(
                                count: streakViewModel.streak?.currentStreak ?? 0,
                                isLoading: streakViewModel.isLoading
                            )
                        }
                    }
                }
            }
            .sheet(isPresented: $showStreakSheet) {
                StreakDetailSheet()
                    .environmentObject(streakViewModel)
            }
    }
}

// MARK: - View Extension

extension View {
    func streakToolbar() -> some View {
        self.modifier(StreakToolbarModifier())
    }
}
