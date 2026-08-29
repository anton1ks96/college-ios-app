//
//  SettingsRow.swift
//  college-ios-app
//

import SwiftUI

struct SettingsRow<Trailing: View>: View {
    @Environment(\.colors) private var colors

    let icon: String
    let title: String
    var tint: Color?
    @ViewBuilder let trailing: () -> Trailing

    var body: some View {
        HStack(spacing: 0) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(tint ?? colors.onSurface)
                .frame(width: 22, height: 22)

            Text(title)
                .textStyle(AppType.bodyLarge)
                .foregroundStyle(tint ?? colors.onSurface)
                .padding(.leading, 16)
                .frame(maxWidth: .infinity, alignment: .leading)

            trailing()
        }
        .padding(16)
        .contentShape(Rectangle())
    }
}

struct SettingsRowButtonStyle: ButtonStyle {
    @Environment(\.colors) private var colors

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(configuration.isPressed ? colors.onSurface.opacity(0.06) : .clear)
    }
}

struct SettingsLinkRow: View {
    @Environment(\.colors) private var colors

    let icon: String
    let title: String
    let url: URL

    var body: some View {
        Link(destination: url) {
            SettingsRow(icon: icon, title: title) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(colors.onSurfaceVariant)
                    .accessibilityHidden(true)
            }
        }
        .buttonStyle(SettingsRowButtonStyle())
        .accessibilityElement(children: .combine)
    }
}
