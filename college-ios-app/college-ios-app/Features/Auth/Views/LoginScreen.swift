//
//  LoginScreen.swift
//  college-ios-app
//

import SwiftUI

struct LoginScreen: View {
    let onClose: () -> Void

    var body: some View {
        VStack {
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay(alignment: .topLeading) {
            Button("Закрыть", action: onClose)
                .padding(20)
        }
    }
}

#Preview {
    LoginScreen(onClose: {})
}
