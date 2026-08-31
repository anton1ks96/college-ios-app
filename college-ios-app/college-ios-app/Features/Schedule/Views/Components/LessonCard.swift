//
//  LessonCard.swift
//  college-ios-app
//

import SwiftUI

private let cardPadding: CGFloat = 11
private let watermarkSize: CGFloat = 76
private let pastOpacity: Double = 0.55

struct LessonCard: View {
    @Environment(\.colors) private var colors

    let lesson: Lesson
    let minHeight: CGFloat
    let isPast: Bool
    let isNow: Bool
    let remaining: Int?
    let onTap: () -> Void

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: Metrics.cardRadius, style: .continuous)
    }

    var body: some View {
        Button(action: onTap) {
            content
                .padding(cardPadding)
                .frame(maxWidth: .infinity, minHeight: minHeight, alignment: .topLeading)
                .background(alignment: .bottomTrailing) { watermark }
                .clipShape(shape)
                .accentGlass(shape, interactive: true)
                .overlay {
                    if isNow {
                        shape.strokeBorder(.white.opacity(0.85), lineWidth: 2)
                    }
                }
                .background(alignment: .bottom) {
                    if isNow { glow }
                }
        }
        .buttonStyle(.plain)
        .opacity(isPast ? pastOpacity : 1)
        .accessibilityElement(children: .combine)
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 0) {
            TimePill(text: timeRange, showsCheck: isPast, accent: colors.primary)

            Text(lesson.displayTitle)
                .textStyle(AppType.titleLarge)
                .foregroundStyle(.white)
                .lineLimit(2)
                .padding(.top, 8)

            if !lesson.topic.isEmpty {
                Text(lesson.topic)
                    .textStyle(AppType.bodyMedium)
                    .foregroundStyle(.white.opacity(0.75))
                    .lineLimit(2)
                    .padding(.top, 2)
            }

            chips.padding(.top, 8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var chips: some View {
        GlassGroup {
            FlowLayout {
                if let remaining {
                    LessonChip(text: "Идёт · осталось \(remaining) мин", symbol: "clock")
                }
                if !lesson.room.isEmpty {
                    LessonChip(text: lesson.room, symbol: "mappin.and.ellipse")
                }
                if !lesson.subgroups.isEmpty {
                    LessonChip(text: "Подгруппы: \(lesson.subgroups.count)", symbol: "list.bullet")
                }
            }
        }
    }

    private var watermark: some View {
        Image(systemName: SubjectIcon.symbol(for: lesson.title))
            .font(.system(size: watermarkSize, weight: .light))
            .foregroundStyle(.white.opacity(0.13))
            .offset(x: 8, y: 8)
            .accessibilityHidden(true)
    }

    private var glow: some View {
        LinearGradient(
            stops: [
                .init(color: .clear, location: 0),
                .init(color: .violetLight.opacity(0.45), location: 0.25),
                .init(color: .violetTint.opacity(0.65), location: 0.5),
                .init(color: .violetLight.opacity(0.45), location: 0.75),
                .init(color: .clear, location: 1),
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
        .frame(height: 10)
        .blur(radius: 24)
        .padding(.horizontal, 20)
        .offset(y: 8)
        .accessibilityHidden(true)
    }

    private var timeRange: String {
        "\(ScheduleFormat.time(lesson.start)) - \(ScheduleFormat.time(lesson.end))"
    }
}

private struct TimePill: View {
    let text: String
    let showsCheck: Bool
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

private struct LessonChip: View {
    let text: String
    let symbol: String

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: symbol)
                .font(.system(size: 11, weight: .semibold))
            Text(text)
                .textStyle(AppType.labelSmall)
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .glassSurface(Capsule(), style: .clear)
        .overlay(Capsule().stroke(.white.opacity(0.5), lineWidth: 1))
    }
}

#Preview {
    let day = ScheduleCalendar.day(of: .now)

    return VStack(spacing: 12) {
        LessonCard(
            lesson: ScheduleMocks.lessons(day: day, weekday: 0)[0],
            minHeight: 150,
            isPast: false,
            isNow: true,
            remaining: 24,
            onTap: {}
        )
        LessonCard(
            lesson: ScheduleMocks.lessons(day: day, weekday: 0)[2],
            minHeight: 150,
            isPast: true,
            isNow: false,
            remaining: nil,
            onTap: {}
        )
    }
    .padding(16)
    .appBackground()
    .environment(\.colors, .dark)
}
