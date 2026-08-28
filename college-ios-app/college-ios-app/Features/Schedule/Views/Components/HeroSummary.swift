//
//  HeroSummary.swift
//  college-ios-app
//

import SwiftUI

struct HeroSummary: View {
    @Environment(\.colors) private var colors

    let caption: String
    let value: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(caption)
                .textStyle(AppType.labelLarge)
                .foregroundStyle(colors.onSurfaceVariant)

            Text(value)
                .textStyle(AppType.heroValue)
                .foregroundStyle(colors.onBackground)
                .lineLimit(1)
                .minimumScaleFactor(0.6)

            Text(subtitle)
                .textStyle(AppType.bodyLarge)
                .foregroundStyle(colors.onSurfaceVariant)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    HeroSummary(
        caption: "Неделя 24 – 30 августа",
        value: "4 пары",
        subtitle: "Понедельник, 24 августа · 9:00 – 15:50"
    )
    .padding()
    .appBackground()
    .environment(\.colors, .dark)
}
