//
//  TimePill.swift
//  college-ios-app
//

import SwiftUI

struct TimePill: View {
    let text: String
    var showsCheck: Bool = false
    let accent: Color

    var body: some View {
        HStack(spacing: 4) {
            if showsCheck {
                Image(systemName: "checkmark")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 28, height: 28)
                    .background(accent, in: Circle())
            }

            Text(text)
                .textStyle(AppType.labelLarge)
                .fontWeight(.bold)
                .foregroundStyle(accent)
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
        }
        .padding(4)
        .background(.white, in: Capsule())
    }
}

#Preview {
    VStack(spacing: 12) {
        TimePill(text: "9:00 - 10:30", accent: .violet)
        TimePill(text: "12:40 - 14:10", showsCheck: true, accent: .violet)
    }
    .padding(20)
    .appBackground()
    .environment(\.colors, .dark)
}
