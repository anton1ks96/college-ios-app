//
//  ScheduleScreen.swift
//  college-ios-app
//

import SwiftUI

struct ScheduleScreen: View {
    @Environment(\.colors) private var colors
    @State private var viewModel: ScheduleViewModel

    @AppStorage(ScheduleDefaultsKey.view) private var scheduleView: ScheduleView = .threeDays
    @AppStorage(ScheduleDefaultsKey.skipWeekends) private var skipWeekends: Bool = false

    init(viewModel: ScheduleViewModel = ScheduleViewModel()) {
        _viewModel = State(wrappedValue: viewModel)
    }

    private var settings: ScheduleSettings {
        ScheduleSettings(view: scheduleView, skipWeekends: skipWeekends)
    }

    private var state: ScheduleState { viewModel.state }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 20) {
                    HeroSummary(caption: caption, value: value, subtitle: subtitle)

                    WeekNav(
                        onToday: viewModel.goToToday,
                        onPrevious: { viewModel.shiftWeek(by: -1) },
                        onNext: { viewModel.shiftWeek(by: 1) }
                    )
                }
                .padding(.horizontal, Metrics.screenPadding)

                WeekStrip(
                    days: state.days,
                    selected: Set(state.visible.map(\.date)),
                    onSelect: viewModel.select(date:)
                )
                .padding(.horizontal, 16)
            }
            .padding(.top, 8)
            .padding(.bottom, 24)
            .animation(.snappy(duration: 0.28), value: state.visible)
        }
        .appBackground()
        .navigationTitle("Расписание")
        .refreshable { await viewModel.retry() }
        .task { await viewModel.start() }
        .onChange(of: settings) { _, updated in viewModel.apply(settings: updated) }
    }

    private var caption: String {
        let end = ScheduleCalendar.adding(days: 6, to: state.weekStart)
        return "Неделя \(ScheduleFormat.dateRange(from: state.weekStart, to: end))"
    }

    private var value: String {
        if state.isLoading { return "Загружаем…" }
        if state.error != nil { return "Нет данных" }
        return state.lessonCount == 0 ? "Пар нет" : ScheduleFormat.lessonsCount(state.lessonCount)
    }

    private var subtitle: String {
        guard let first = state.visible.first, let last = state.visible.last else { return "" }
        guard state.visible.count == 1 else {
            return ScheduleFormat.dateRange(from: first.date, to: last.date)
        }
        return ScheduleFormat.dayTitle(first.date) + dayHours(first.lessons)
    }

    private func dayHours(_ lessons: [Lesson]) -> String {
        guard let first = lessons.first, let last = lessons.last else { return "" }
        return " · \(ScheduleFormat.time(first.start)) – \(ScheduleFormat.time(last.end))"
    }
}

#Preview {
    NavigationStack {
        ScheduleScreen(viewModel: ScheduleViewModel(repository: MockScheduleRepository()))
    }
}
