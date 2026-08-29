//
//  AttendanceRow.swift
//  college-ios-app
//

import SwiftUI

private let iconSide: CGFloat = 38

struct AttendanceRow: View {
    @Environment(\.colors) private var colors

    let record: AttendanceRecord

    var body: some View {
        HStack(spacing: 12) {
            icon

            VStack(alignment: .leading, spacing: 2) {
                Text(record.title)
                    .textStyle(AppType.bodyLarge)
                    .foregroundStyle(colors.onSurface)
                    .lineLimit(2)

                if !subtitle.isEmpty {
                    Text(subtitle)
                        .textStyle(AppType.bodySmall)
                        .foregroundStyle(colors.onSurfaceVariant)
                        .lineLimit(1)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            statusPill
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .accessibilityElement(children: .combine)
        .accessibilityValue(record.attendance.title)
    }

    private var icon: some View {
        Image(systemName: SubjectIcon.symbol(for: record.title))
            .font(.system(size: 17, weight: .semibold))
            .foregroundStyle(color)
            .frame(width: iconSide, height: iconSide)
            .background(color.opacity(0.14), in: Circle())
    }

    private var statusPill: some View {
        Text(record.attendance.short)
            .textStyle(AppType.labelSmall)
            .foregroundStyle(color)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(color.opacity(0.12), in: Capsule())
    }

    private var color: Color {
        switch record.attendance {
        case .present: colors.success
        case .excused: colors.warning
        case .absent: colors.danger
        case .unknown: colors.onSurfaceVariant
        }
    }

    private var subtitle: String {
        var parts: [String] = []

        if let start = record.start {
            let end = record.end.map { " – \(ScheduleFormat.time($0))" } ?? ""
            parts.append(ScheduleFormat.time(start) + end)
        }
        if !record.room.isEmpty {
            parts.append(record.room)
        }

        return parts.joined(separator: " · ")
    }
}
