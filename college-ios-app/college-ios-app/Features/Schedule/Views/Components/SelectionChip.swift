//
//  SelectionChip.swift
//  college-ios-app
//

import SwiftUI

struct SelectionChip: View {
    @Environment(\.colors) private var colors

    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .textStyle(AppType.labelLarge)
                .foregroundStyle(isSelected ? colors.onTertiary : colors.onSurface)
                .lineLimit(1)
                .padding(.horizontal, 14)
                .padding(.vertical, 9)
        }
        .buttonStyle(.plain)
        .glassSurface(Capsule(), tint: isSelected ? colors.primary : nil, interactive: true)
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }
}

struct SelectionSection<Content: View>: View {
    @Environment(\.colors) private var colors

    let title: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .textStyle(AppType.labelLarge)
                .foregroundStyle(colors.onSurfaceVariant)

            GlassGroup {
                FlowLayout(spacing: 8, lineSpacing: 8) { content() }
            }
        }
        .padding(.top, 20)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
