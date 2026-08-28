//
//  SettingsCard.swift
//  college-ios-app
//

import SwiftUI

struct SettingsSectionTitle: View {
    @Environment(\.colors) private var colors

    let title: String

    init(_ title: String) {
        self.title = title
    }

    var body: some View {
        Text(title)
            .textStyle(AppType.labelLarge)
            .foregroundStyle(colors.onSurfaceVariant)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 32)
            .padding(.trailing, 16)
            .padding(.top, 20)
            .padding(.bottom, 6)
    }
}

struct SettingsCard<Content: View>: View {
    @ViewBuilder let content: () -> Content

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: Metrics.cardRadius, style: .continuous)
    }

    var body: some View {
        VStack(spacing: 0) {
            content()
        }
        .clipShape(shape)
        .glassSurface(shape)
        .padding(.horizontal, 16)
    }
}

struct SettingsDivider: View {
    @Environment(\.colors) private var colors

    var body: some View {
        Rectangle()
            .fill(colors.onSurface.opacity(Metrics.hairlineOpacity))
            .frame(height: 1)
            .padding(.leading, 54)
    }
}
