//
//  HomeViewModel.swift
//  college-ios-app
//

import Foundation

@Observable
final class HomeViewModel {

    private(set) var state: HomeState

    private let repository: HomeRepositoryProtocol

    private var loadTask: Task<Void, Never>?
    private var scoresTask: Task<Void, Never>?

    init(repository: HomeRepositoryProtocol = AppDependencies.homeRepository) {
        self.repository = repository
        state = HomeState(weekStart: ScheduleCalendar.monday(of: .now))
    }

    // MARK: - Intents

    func sync(user: User?, isBootstrapping: Bool) {
        let wasAuthenticated = state.isAuthenticated

        state.user = user
        state.isBootstrapping = isBootstrapping

        if user == nil {
            clear()
            return
        }

        if !wasAuthenticated {
            Task { await reload() }
        }
    }

    func refresh() async {
        guard state.isAuthenticated else { return }
        await reload()
    }

    func shiftWeek(by weeks: Int) {
        state.weekStart = ScheduleCalendar.adding(weeks: weeks, to: state.weekStart)
        Task { await reload() }
    }

    func goToCurrentWeek() {
        let monday = ScheduleCalendar.monday(of: .now)
        guard monday != state.weekStart else { return }
        state.weekStart = monday
        Task { await reload() }
    }

    func openSubject(_ subject: Subject) {
        scoresTask?.cancel()
        state.scores = SubjectScores(subject: subject)

        let bounds = HomeSemester.bounds(for: .now)
        scoresTask = Task { [repository] in
            do {
                let lessons = try await repository.scores(
                    subjectID: subject.id,
                    start: bounds.start,
                    end: bounds.end
                )
                guard state.scores?.subject.id == subject.id else { return }
                state.scores?.lessons = lessons
                state.scores?.isLoading = false
            } catch {
                guard !isCancellation(error), state.scores?.subject.id == subject.id else { return }
                state.scores?.isLoading = false
                state.scores?.error = message(for: error) ?? "Не удалось загрузить баллы"
            }
        }
    }

    func closeSubject() {
        scoresTask?.cancel()
        state.scores = nil
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

        await loadAttendance()
        await loadStreak()
        await loadSubjects()

        guard !Task.isCancelled else { return }
        state.isLoading = false
    }

    private func loadAttendance() async {
        do {
            let records = try await repository.attendance(monday: state.weekStart)
            try Task.checkCancellation()
            state.records = records
            state.days = HomeParsing.days(from: records)
            state.stats = AttendanceStats.of(records)
            state.error = nil
        } catch {
            guard !isCancellation(error) else { return }
            state.records = []
            state.days = []
            state.stats = .empty
            state.error = message(for: error) ?? "Не удалось загрузить посещаемость"
        }
    }

    private func loadStreak() async {
        do {
            let streak = try await repository.streak()
            try Task.checkCancellation()
            state.streak = streak
        } catch {
            return
        }
    }

    private func loadSubjects() async {
        do {
            let subjects = try await repository.subjects()
            try Task.checkCancellation()
            state.subjects = subjects
        } catch {
            return
        }
    }

    private func clear() {
        loadTask?.cancel()
        scoresTask?.cancel()
        state.records = []
        state.days = []
        state.stats = .empty
        state.streak = nil
        state.subjects = []
        state.scores = nil
        state.error = nil
        state.isLoading = false
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
