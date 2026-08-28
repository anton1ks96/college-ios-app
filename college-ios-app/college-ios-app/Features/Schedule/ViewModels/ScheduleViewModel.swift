//
//  ScheduleViewModel.swift
//  college-ios-app
//

import Foundation
import Observation

@Observable
final class ScheduleViewModel {

    private(set) var state: ScheduleState

    private let repository: ScheduleRepositoryProtocol
    private let selectionStore: SelectionStore

    private var weekLessons: [Lesson] = []
    private var loadTask: Task<Void, Never>?
    private var detailsTask: Task<Void, Never>?
    private var didStart = false

    init(
        repository: ScheduleRepositoryProtocol = AppDependencies.scheduleRepository,
        selectionStore: SelectionStore = SelectionStore(),
        settingsStore: ScheduleSettingsStore = ScheduleSettingsStore()
    ) {
        self.repository = repository
        self.selectionStore = selectionStore
        let today = ScheduleCalendar.day(of: .now)
        state = ScheduleState(
            weekStart: ScheduleCalendar.monday(of: today),
            selectedDate: today,
            selection: selectionStore.load(),
            settings: settingsStore.load()
        )
    }

    // MARK: - Intents

    func start() async {
        guard !didStart else { return }
        didStart = true
        await reload()
    }

    func retry() async {
        await reload()
    }

    func select(date: Date) {
        state.selectedDate = date
        applyWeek()
    }

    func shiftWeek(by weeks: Int) {
        let weekStart = ScheduleCalendar.adding(weeks: weeks, to: state.weekStart)
        state.weekStart = weekStart
        state.selectedDate = weekStart
        Task { await reload() }
    }

    func goToToday() {
        let today = ScheduleCalendar.day(of: .now)
        let weekStart = ScheduleCalendar.monday(of: today)
        guard weekStart != state.weekStart else {
            select(date: today)
            return
        }
        state.weekStart = weekStart
        state.selectedDate = today
        Task { await reload() }
    }

    func update(selection: Selection) {
        guard selection != state.selection else { return }
        state.selection = selection
        selectionStore.save(selection)
        Task { await reload() }
    }

    func apply(settings: ScheduleSettings) {
        guard settings != state.settings else { return }
        state.settings = settings
        guard state.error == nil else { return }
        applyWeek()
    }

    func openLesson(_ lesson: Lesson) {
        state.details = LessonDetails(lesson: lesson)
        detailsTask?.cancel()
        detailsTask = Task { [repository] in
            do {
                let rows = try await repository.classDetails(id: lesson.id)
                guard state.details?.lesson.id == lesson.id else { return }
                state.details?.rows = rows
                state.details?.isLoading = false
            } catch {
                guard !isCancellation(error), state.details?.lesson.id == lesson.id else { return }
                state.details?.isLoading = false
                state.details?.error = message(for: error)
            }
        }
    }

    func closeLesson() {
        detailsTask?.cancel()
        state.details = nil
    }

    // MARK: - Loading

    private func reload() async {
        loadTask?.cancel()
        let task = Task { await performLoad() }
        loadTask = task
        _ = await task.value
    }

    private func performLoad() async {
        state.isLoading = true
        do {
            let lessons = try await repository.weekSchedule(
                monday: state.weekStart,
                selection: state.selection
            )
            try Task.checkCancellation()
            weekLessons = lessons
            state.error = nil
            state.isLoading = false
            applyWeek()
        } catch {
            guard !isCancellation(error) else { return }
            weekLessons = []
            state.days = []
            state.visible = []
            state.isLoading = false
            state.error = message(for: error) ?? "Не удалось загрузить расписание"
        }
    }

    private func applyWeek() {
        let today = ScheduleCalendar.day(of: .now)
        let byDate = Dictionary(grouping: weekLessons, by: \.day)
        let dates = ScheduleDays.week(from: state.weekStart, settings: state.settings)

        state.days = dates.map {
            DayCell(date: $0, lessonCount: byDate[$0]?.count ?? 0, isToday: $0 == today)
        }
        state.visible = ScheduleDays
            .visible(in: dates, selected: state.selectedDate, settings: state.settings)
            .map { DaySchedule(date: $0, lessons: (byDate[$0] ?? []).sorted { $0.start < $1.start }) }
    }

    private func isCancellation(_ error: Error) -> Bool {
        if error is CancellationError { return true }
        if case APIError.cancelled = error { return true }
        return false
    }

    private func message(for error: Error) -> String? {
        (error as? LocalizedError)?.errorDescription
    }
}
