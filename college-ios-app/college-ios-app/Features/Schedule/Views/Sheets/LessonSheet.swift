//
//  LessonSheet.swift
//  college-ios-app
//

import SwiftUI

struct LessonSheet: View {
    @Environment(\.colors) private var colors

    let details: LessonDetails
    var onSelect: (LessonSubgroup?) -> Void = { _ in }

    private var lesson: Lesson { details.lesson }

    private var showsDetails: Bool {
        details.isLoading || details.error != nil || !details.rows.isEmpty
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text("\(ScheduleFormat.time(lesson.start)) – \(ScheduleFormat.time(lesson.end))")
                    .textStyle(AppType.labelLarge)
                    .foregroundStyle(colors.primary)

                Text(lesson.title)
                    .textStyle(AppType.titleLarge)
                    .foregroundStyle(colors.onSurface)
                    .padding(.top, 4)

                caption(lesson.topic)
                caption(lesson.room.isEmpty ? "" : "Кабинет \(lesson.room)")

                ForEach(lesson.subgroups) { subgroup in
                    divider

                    Button {
                        onSelect(details.selected == subgroup ? nil : subgroup)
                    } label: {
                        subgroupBody(subgroup)
                    }
                    .buttonStyle(.plain)
                    .disabled(subgroup.classID.isEmpty)
                    .accessibilityHint(
                        details.selected == subgroup
                            ? "Скрыть подробности подгруппы"
                            : "Показать подробности подгруппы"
                    )
                }

                if showsDetails {
                    divider

                    Text(details.selected.map { "Подробности - \($0.id)" } ?? "Подробности")
                        .textStyle(AppType.labelLarge)
                        .foregroundStyle(colors.onSurfaceVariant)

                    Fade(value: phaseOf(isLoading: details.isLoading, error: details.error)) { phase in
                        rows(for: phase)
                    }
                    .padding(.top, 8)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 24)
            .padding(.horizontal, Metrics.screenPadding)
            .padding(.bottom, 32)
        }
        .appBackground()
    }

    private func subgroupBody(_ subgroup: LessonSubgroup) -> some View {
        let isSelected = details.selected == subgroup

        return VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 6) {
                Text(subgroup.id)
                    .textStyle(AppType.labelLarge)
                    .foregroundStyle(colors.primary)

                if !subgroup.classID.isEmpty {
                    Image(systemName: isSelected ? "chevron.up" : "chevron.down")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(colors.onSurfaceVariant)
                }
            }

            Text(subgroup.title)
                .textStyle(AppType.titleMedium)
                .foregroundStyle(isSelected ? colors.primary : colors.onSurface)
                .padding(.top, 2)

            caption(subgroup.topic)
            caption(subgroup.room.isEmpty ? "" : "Кабинет \(subgroup.room)")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
    }

    @ViewBuilder
    private func rows(for phase: Phase) -> some View {
        switch phase {
        case .loading:
            Swirl().frame(width: 24, height: 24)

        case .error:
            caption(details.error ?? "")

        default:
            VStack(alignment: .leading, spacing: 8) {
                ForEach(details.rows) { row in
                    HStack(alignment: .top, spacing: 12) {
                        Text(row.key)
                            .textStyle(AppType.bodyMedium)
                            .foregroundStyle(colors.onSurfaceVariant)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Text(row.value)
                            .textStyle(AppType.bodyMedium)
                            .foregroundStyle(colors.onSurface)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func caption(_ text: String) -> some View {
        if !text.isEmpty {
            Text(text)
                .textStyle(AppType.bodyMedium)
                .foregroundStyle(colors.onSurfaceVariant)
                .padding(.top, 4)
        }
    }

    private var divider: some View {
        Rectangle()
            .fill(colors.onSurface.opacity(Metrics.hairlineOpacity))
            .frame(height: 1)
            .padding(.vertical, 16)
    }
}

#Preview {
    let lesson = ScheduleMocks.lessons(day: ScheduleCalendar.day(of: .now), weekday: 0)[2]

    return LessonSheet(
        details: LessonDetails(
            lesson: lesson,
            rows: [DetailRow(key: "teacher", value: "Иванов И. И.")],
            isLoading: false
        )
    )
    .environment(\.colors, .dark)
}
