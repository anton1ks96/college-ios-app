//
//  StatsRow.swift
//  college-ios-app
//

import SwiftUI

private let statRadius: CGFloat = 18

struct StatsRow: View {
    @Environment(\.colors) private var colors

    let stats: AttendanceStats

    var body: some View {
        GlassGroup(spacing: 12) {
            HStack(spacing: 12) {
                card(title: "Был", value: stats.present, color: colors.success)
                card(title: "Ув.", value: stats.excused, color: colors.warning)
                card(title: "Н/У", value: stats.absent, color: colors.danger)
            }
        }
    }

    private func card(title: String, value: Int, color: Color) -> some View {
        VStack(spacing: 2) {
            Text("\(value)")
                .textStyle(AppType.titleLarge)
                .foregroundStyle(color)

            Text(title)
                .textStyle(AppType.labelMedium)
                .foregroundStyle(colors.onSurfaceVariant)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .glassSurface(RoundedRectangle(cornerRadius: statRadius, style: .continuous))
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    StatsRow(stats: AttendanceStats(total: 16, present: 12, absent: 2, excused: 2))
        .padding(20)
        .appBackground()
        .environment(\.colors, .dark)
}
