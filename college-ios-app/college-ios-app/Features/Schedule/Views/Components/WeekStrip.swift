//
//  WeekStrip.swift
//  college-ios-app
//

import SwiftUI

private let circleSide: CGFloat = 44
private let dotSide: CGFloat = 4
private let maxDots = 4

struct WeekStrip: View {
    @Environment(\.colors) private var colors
    @Namespace private var glass

    let days: [DayCell]
    let selected: Set<Date>
    let onSelect: (Date) -> Void

    var body: some View {
        GlassGroup(spacing: 8) {
            HStack(spacing: 4) {
                ForEach(days) { day in
                    item(day)
                }
            }
        }
    }

    private func item(_ day: DayCell) -> some View {
        let isSelected = selected.contains(day.date)
        return Button {
            onSelect(day.date)
        } label: {
            VStack(spacing: 6) {
                Text(ScheduleFormat.weekdayShort(day.date))
                    .textStyle(AppType.labelLarge)
                    .foregroundStyle(day.isToday ? colors.primary : colors.onSurfaceVariant)

                circle(day, isSelected: isSelected)
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(ScheduleFormat.dayTitle(day.date))
        .accessibilityValue(ScheduleFormat.lessonsCount(day.lessonCount))
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }

    @ViewBuilder
    private func circle(_ day: DayCell, isSelected: Bool) -> some View {
        let content = numbers(day, isSelected: isSelected)

        if isSelected {
            content
                .glassSurface(Circle(), tint: colors.primary, interactive: true)
                .glassMorph(id: day.date, in: glass)
        } else {
            content
                .background(colors.surfaceVariant, in: Circle())
        }
    }

    private func numbers(_ day: DayCell, isSelected: Bool) -> some View {
        let tint = isSelected ? colors.onTertiary : colors.onSurface

        return VStack(spacing: 0) {
            Text(day.date, format: .dateTime.day())
                .textStyle(AppType.titleMedium)
                .foregroundStyle(tint)

            LessonDots(count: day.lessonCount, color: tint)
        }
        .frame(width: circleSide, height: circleSide)
    }
}

private struct LessonDots: View {
    let count: Int
    let color: Color

    var body: some View {
        HStack(spacing: 3) {
            ForEach(0..<min(count, maxDots), id: \.self) { _ in
                Circle()
                    .fill(color.opacity(0.7))
                    .frame(width: dotSide, height: dotSide)
            }
        }
        .frame(height: dotSide, alignment: .top)
        .padding(.top, 3)
    }
}

#Preview {
    let monday = ScheduleCalendar.monday(of: .now)
    let days = (0..<7).map { offset -> DayCell in
        let date = ScheduleCalendar.adding(days: offset, to: monday)
        return DayCell(date: date, lessonCount: offset % 5, isToday: offset == 2)
    }

    return WeekStrip(
        days: days,
        selected: Set(days[2...4].map(\.date)),
        onSelect: { _ in }
    )
    .padding(.horizontal, 16)
    .appBackground()
    .environment(\.colors, .dark)
}
