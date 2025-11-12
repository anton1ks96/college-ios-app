//
//  AccountToolbarModifier.swift
//  college-ios-app
//
//  Created by pc on 12.11.2025.
//

import SwiftUI

struct AccountToolbarModifier: ViewModifier {
    @EnvironmentObject var sessionViewModel: SessionViewModel
    @State private var showLoginSheet = false
    @State private var showAccountSheet = false
    
    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if sessionViewModel.isAuthenticated {
                            showAccountSheet = true
                        } else {
                            showLoginSheet = true
                        }
                    } label: {
                        Image(systemName: sessionViewModel.isAuthenticated ? "person.circle.fill" : "rectangle.portrait.and.arrow.forward")
                    }
                }
            }
            .sheet(isPresented: $showLoginSheet) {
                LoginView()
                    .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showAccountSheet) {
                AccountSheetView()
                    .environmentObject(sessionViewModel)
                    .presentationDragIndicator(.visible)
            }
    }
}

// MARK: - View Extension

extension View {
    func accountToolbar() -> some View {
        self.modifier(AccountToolbarModifier())
    }
}
