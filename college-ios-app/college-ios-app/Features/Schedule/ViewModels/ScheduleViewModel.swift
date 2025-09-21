//
//  ScheduleViewModel.swift
//  college-ios-app
//
//  Created by pc on 21.09.2025.
//

import Foundation
import SwiftUI
internal import Combine

@MainActor
final class ScheduleViewModel: ObservableObject {

    // MARK: - Dependencies
    private let repository: ScheduleRepositoryProtocol

    // MARK: - Input state (UI bindings)
    @Published var selectedGroup: String
    @Published var selectedSubgroup: String
    @Published var dateRange: DateRange

    // MARK: - Output state (read-only for View)
    @Published private(set) var events: [ScheduleEvent] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String?

    // MARK: - Internal
    private var currentTask: Task<Void, Never>?
    private var didInitialLoad = false

    // MARK: - Init
    init(repository: ScheduleRepositoryProtocol) {
        self.repository = repository

        self.selectedGroup = GroupsCatalog.allGroups.first ?? ""
        self.selectedSubgroup = SubgroupsCatalog.allSubgroups.first ?? "0"

        let today = Date()
        let end = Calendar.current.date(byAdding: .day, value: 2, to: today) ?? today
        self.dateRange = DateRange(start: today, end: end)
    }

    deinit {
        currentTask?.cancel()
    }

    // MARK: - Lifecycle hook
    func onAppearOnce() {
        guard !didInitialLoad else { return }
        didInitialLoad = true
        loadSchedule()
    }

    // MARK: - User intents (updates)
    func updateGroup(_ group: String) {
        selectedGroup = group
    }

    func updateSubgroup(_ subgroup: String) {
        selectedSubgroup = subgroup
    }

    func updateDateRange(start: Date, end: Date) {
        dateRange = DateRange(start: start, end: end)
    }

    func setQuickRange(daysFromToday days: Int) {
        let start = Date()
        let end = Calendar.current.date(byAdding: .day, value: days, to: start) ?? start
        dateRange = DateRange(start: start, end: end)
    }

    // MARK: - Loading
    func loadSchedule() {
        currentTask?.cancel()

        isLoading = true
        errorMessage = nil

        let group = selectedGroup
        let subgroup = selectedSubgroup
        let start = dateRange.start
        let end = dateRange.end

        currentTask = Task { [weak self] in
            guard let self else { return }
            do {
                let loaded = try await self.repository.getSchedule(
                    group: group,
                    subgroup: subgroup,
                    start: start,
                    end: end
                )
                try Task.checkCancellation()
                self.events = loaded
                self.isLoading = false
            } catch is CancellationError {
                
            } catch {
                self.events = []
                self.isLoading = false
                self.errorMessage = localizedMessage(from: error)
            }
        }
    }

    func retry() {
        loadSchedule()
    }

    // MARK: - Derived for UI
    var eventsByDay: [String: [ScheduleEvent]] {
        Dictionary(grouping: events, by: { $0.day })
    }

    var sortedDays: [String] {
        eventsByDay.keys.sorted()
    }

    func formattedDay(_ day: String) -> String {
        if let date = DateFormatters.request.date(from: day) {
            return DateFormatters.uiDate.string(from: date)
        }
        return day
    }

    // MARK: - Helpers
    private func localizedMessage(from error: Error) -> String {
        if let err = error as? LocalizedError, let msg = err.errorDescription {
            return msg
        }
        return "Не удалось загрузить расписание. Попробуйте ещё раз."
    }
}
