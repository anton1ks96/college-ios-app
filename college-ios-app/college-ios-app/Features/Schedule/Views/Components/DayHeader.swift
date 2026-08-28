//
//  DayHeader.swift
//  college-ios-app
//

import SwiftUI

struct DayHeader: View {
    @Environment(\.colors) private var colors

    let date: Date
    let lessonCount: Int
    let isToday: Bool

    var body: some View {
        row
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .modifier(DayHeaderSurface(isToday: isToday))
            .accessibilityElement(children: .combine)
    }

    private var row: some View {
        HStack(spacing: 12) {
            Text(ScheduleFormat.dayTitle(date))
                .textStyle(AppType.titleMedium)
                .foregroundStyle(isToday ? .white : colors.onSurface)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(lessonCount == 0 ? "Пар нет" : ScheduleFormat.lessonsCount(lessonCount))
                .textStyle(AppType.labelMedium)
                .foregroundStyle(isToday ? .white.opacity(0.8) : colors.onSurfaceVariant)
                .lineLimit(1)
        }
    }
}

private struct DayHeaderSurface: ViewModifier {
    let isToday: Bool

    @ViewBuilder
    func body(content: Content) -> some View {
        if isToday {
            content.accentGlass(Capsule())
        } else {
            content.glassSurface(Capsule())
        }
    }
}

#Preview {
    VStack(spacing: 14) {
        DayHeader(date: .now, lessonCount: 4, isToday: true)
        DayHeader(date: ScheduleCalendar.adding(days: 1, to: .now), lessonCount: 0, isToday: false)
    }
    .padding(16)
    .appBackground()
    .environment(\.colors, .dark)
}
