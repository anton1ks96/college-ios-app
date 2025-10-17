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
    private var settingsRepository: UserSettingsRepositoryProtocol
    private let widgetBridge: WidgetScheduleBridge
    
    // MARK: - Input state (UI bindings)
    @Published var selectedGroup: String {
        didSet {
            selectedSubgroup = "*"
            selectedEnglishGroup = "*"
            selectedProfileSubgroup = "*"

            settingsRepository.selectedGroup = selectedGroup

            widgetBridge.clearCache()
        }
    }
    
    @Published var selectedSubgroup: String {
        didSet {
            settingsRepository.selectedSubgroup = selectedSubgroup
            
            if !GroupSubgroupCompatibility.shouldShowProfileSubgroup(for: selectedGroup, subgroup: selectedSubgroup, englishGroup: selectedEnglishGroup) {
                selectedProfileSubgroup = "*"
            }
            
            widgetBridge.clearCache()
        }
    }
    
    @Published var selectedEnglishGroup: String {
        didSet {
            settingsRepository.selectedEnglishGroup = selectedEnglishGroup
            
            if !GroupSubgroupCompatibility.shouldShowProfileSubgroup(for: selectedGroup, subgroup: selectedSubgroup, englishGroup: selectedEnglishGroup) {
                selectedProfileSubgroup = "*"
            }
        }
    }
    
    @Published var selectedProfileSubgroup: String {
        didSet {
            settingsRepository.selectedProfileSubgroup = selectedProfileSubgroup
        }
    }
    
    @Published var dateRange: DateRange
    
    // MARK: - Computed property for available subgroups
    var availableSubgroups: [String] {
        GroupSubgroupCompatibility.availableSubgroups(for: selectedGroup)
    }
    
    var availableEnglishGroups: [String] {
        GroupSubgroupCompatibility.getEnglishGroups(for: selectedGroup)
    }
    
    var isEnglishGroupSelectionEnabled: Bool {
        !availableEnglishGroups.isEmpty && selectedSubgroup != "*"
    }
    
    var availableProfileSubgroups: [String] {
        GroupSubgroupCompatibility.getProfileSubgroups()
    }
    
    var isProfileSubgroupSelectionEnabled: Bool {
        GroupSubgroupCompatibility.shouldShowProfileSubgroup(for: selectedGroup, subgroup: selectedSubgroup, englishGroup: selectedEnglishGroup)
    }
    
    // MARK: - Output state (read-only for View)
    @Published var events: [ScheduleEvent] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // MARK: - Internal
    private var currentTask: Task<Void, Never>?
    private var didInitialLoad = false
    private var lastQuickRangeDays: Int? = nil
    
    // MARK: - Init
    init(
        repository: ScheduleRepositoryProtocol,
        settingsRepository: UserSettingsRepositoryProtocol,
        widgetBridge: WidgetScheduleBridge = .shared
    ) {
        self.repository = repository
        self.settingsRepository = settingsRepository
        self.widgetBridge = widgetBridge
        
        self.selectedGroup = settingsRepository.selectedGroup
        
        let validatedSubgroup = GroupSubgroupCompatibility.validatedSubgroup(
            settingsRepository.selectedSubgroup,
            for: settingsRepository.selectedGroup
        )
        self.selectedSubgroup = validatedSubgroup
        
        if validatedSubgroup != settingsRepository.selectedSubgroup {
            self.settingsRepository.selectedSubgroup = validatedSubgroup
        }
        
        self.selectedEnglishGroup = settingsRepository.selectedEnglishGroup
        self.selectedProfileSubgroup = settingsRepository.selectedProfileSubgroup
        
        let defaultView = settingsRepository.defaultScheduleView
        self.lastQuickRangeDays = defaultView.daysFromToday
        let calendar = Calendar.current
        let today = Date()
        let skipWeekends = settingsRepository.skipWeekends
        
        if defaultView.daysFromToday == 6 {
            if skipWeekends {
                let weekday = calendar.component(.weekday, from: today)
                let daysFromMonday = (weekday == 1) ? -6 : (2 - weekday)
                let monday = calendar.date(byAdding: .day, value: daysFromMonday, to: today) ?? today
                let friday = calendar.date(byAdding: .day, value: 4, to: monday) ?? monday
                self.dateRange = DateRange(start: monday, end: friday)
            } else {
                let weekday = calendar.component(.weekday, from: today)
                let daysFromMonday = (weekday == 1) ? -6 : (2 - weekday)
                let monday = calendar.date(byAdding: .day, value: daysFromMonday, to: today) ?? today
                let sunday = calendar.date(byAdding: .day, value: 6, to: monday) ?? monday
                self.dateRange = DateRange(start: monday, end: sunday)
            }
        } else {
            let start = today
            
            if skipWeekends {
                var currentDate = start
                var workingDaysFound = 0
                let targetDays = defaultView.daysFromToday + 1
                
                while workingDaysFound < targetDays {
                    let weekday = calendar.component(.weekday, from: currentDate)
                    if weekday != 1 && weekday != 7 {
                        workingDaysFound += 1
                    }
                    if workingDaysFound < targetDays {
                        currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
                    }
                }
                
                self.dateRange = DateRange(start: start, end: currentDate)
            } else {
                let end = calendar.date(byAdding: .day, value: defaultView.daysFromToday, to: start) ?? start
                self.dateRange = DateRange(start: start, end: end)
            }
        }
    }
    
    deinit {
        currentTask?.cancel()
    }
    
    // MARK: - Lifecycle hook
    func onAppearOnce() {
        guard !didInitialLoad else { return }
        didInitialLoad = true
        loadSchedule()
        
        BackgroundScheduleUpdater.shared.scheduleAppRefresh()
    }
    
    // MARK: - User intents (updates)
    func updateGroup(_ group: String) {
        selectedGroup = group
    }
    
    func updateSubgroup(_ subgroup: String) {
        if GroupSubgroupCompatibility.isValidSubgroup(subgroup, for: selectedGroup) {
            selectedSubgroup = subgroup
        }
    }
    
    func updateEnglishGroup(_ englishGroup: String) {
        selectedEnglishGroup = englishGroup
    }
    
    func updateProfileSubgroup(_ profileSubgroup: String) {
        selectedProfileSubgroup = profileSubgroup
    }
    
    func updateDateRange(start: Date, end: Date) {
        lastQuickRangeDays = nil
        dateRange = DateRange(start: start, end: end)
    }
    
    func setQuickRange(daysFromToday days: Int) {
        lastQuickRangeDays = days
        dateRange = calculateQuickRange(daysFromToday: days)
    }
    
    func shiftDateRange(by direction: Int) {
        let calendar = Calendar.current
        let skipWeekends = settingsRepository.skipWeekends
        
        if skipWeekends {
            var workingDaysCount = 0
            var currentDate = dateRange.start
            
            while currentDate <= dateRange.end {
                let weekday = calendar.component(.weekday, from: currentDate)
                if weekday != 1 && weekday != 7 {
                    workingDaysCount += 1
                }
                guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else { break }
                currentDate = nextDate
            }
            
            if direction > 0 {
                guard let dayAfterEnd = calendar.date(byAdding: .day, value: 1, to: dateRange.end) else { return }
                let newStart = dayAfterEnd
                let newEnd = findWorkingDayEnd(from: newStart, workingDaysCount: workingDaysCount, calendar: calendar)
                dateRange = DateRange(start: newStart, end: newEnd)
            } else {
                guard let dayBeforeStart = calendar.date(byAdding: .day, value: -1, to: dateRange.start) else { return }
                let newEnd = dayBeforeStart
                let newStart = findWorkingDayStart(before: newEnd, workingDaysCount: workingDaysCount, calendar: calendar)
                dateRange = DateRange(start: newStart, end: newEnd)
            }
        } else {
            let daysCount = calendar.dateComponents([.day], from: dateRange.start, to: dateRange.end).day ?? 0
            guard let newStart = calendar.date(byAdding: .day, value: (daysCount + 1) * direction, to: dateRange.start),
                  let newEnd = calendar.date(byAdding: .day, value: (daysCount + 1) * direction, to: dateRange.end)
            else { return }
            
            dateRange = DateRange(start: newStart, end: newEnd)
        }
    }
    
    private func findWorkingDayStart(before endDate: Date, workingDaysCount: Int, calendar: Calendar) -> Date {
        var currentDate = endDate
        var workingDaysFound = 0
        
        while workingDaysFound < workingDaysCount {
            let weekday = calendar.component(.weekday, from: currentDate)
            if weekday != 1 && weekday != 7 {
                workingDaysFound += 1
            }
            
            if workingDaysFound < workingDaysCount {
                currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
            }
        }
        
        return currentDate
    }
    
    func calculateQuickRange(daysFromToday days: Int) -> DateRange {
        let calendar = Calendar.current
        let today = Date()
        let skipWeekends = settingsRepository.skipWeekends
        
        if days == 6 {
            if skipWeekends {
                let weekday = calendar.component(.weekday, from: today)
                let daysFromMonday = (weekday == 1) ? -6 : (2 - weekday)
                let monday = calendar.date(byAdding: .day, value: daysFromMonday, to: today) ?? today
                let friday = calendar.date(byAdding: .day, value: 4, to: monday) ?? monday
                return DateRange(start: monday, end: friday)
            } else {
                let weekday = calendar.component(.weekday, from: today)
                let daysFromMonday = (weekday == 1) ? -6 : (2 - weekday)
                let monday = calendar.date(byAdding: .day, value: daysFromMonday, to: today) ?? today
                let sunday = calendar.date(byAdding: .day, value: 6, to: monday) ?? monday
                return DateRange(start: monday, end: sunday)
            }
        } else {
            let start = today
            
            if skipWeekends {
                let end = findWorkingDayEnd(from: start, workingDaysCount: days + 1, calendar: calendar)
                return DateRange(start: start, end: end)
            } else {
                let end = calendar.date(byAdding: .day, value: days, to: start) ?? start
                return DateRange(start: start, end: end)
            }
        }
    }
    
    private func findWorkingDayEnd(from startDate: Date, workingDaysCount: Int, calendar: Calendar) -> Date {
        var currentDate = startDate
        var workingDaysFound = 0
        
        while workingDaysFound < workingDaysCount {
            let weekday = calendar.component(.weekday, from: currentDate)
            if weekday != 1 && weekday != 7 {
                workingDaysFound += 1
            }
            
            if workingDaysFound < workingDaysCount {
                currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
            }
        }
        
        return currentDate
    }
    
    // MARK: - Settings management
    func resetSettings() {
        selectedGroup = settingsRepository.selectedGroup
        let validatedSubgroup = GroupSubgroupCompatibility.validatedSubgroup(
            settingsRepository.selectedSubgroup,
            for: settingsRepository.selectedGroup
        )
        selectedSubgroup = validatedSubgroup
        selectedEnglishGroup = settingsRepository.selectedEnglishGroup
        selectedProfileSubgroup = settingsRepository.selectedProfileSubgroup
        loadSchedule()
    }
    
    func recalculateDateRangeIfNeeded() {
        if let days = lastQuickRangeDays {
            dateRange = calculateQuickRange(daysFromToday: days)
            loadSchedule()
        } else {
            loadSchedule()
        }
    }
    
    // MARK: - Loading
    func loadSchedule() {
        currentTask?.cancel()
        
        isLoading = true
        errorMessage = nil
        
        let group = selectedGroup
        let subgroup = selectedSubgroup
        let englishGroup = selectedEnglishGroup
        let profileSubgroup = selectedProfileSubgroup
        let start = dateRange.start
        let end = dateRange.end
        
        currentTask = Task { [weak self] in
            guard let self else { return }
            do {
                let loaded = try await self.repository.getSchedule(
                    group: group,
                    subgroup: subgroup,
                    englishGroup: englishGroup,
                    profileSubgroup: profileSubgroup,
                    start: start,
                    end: end
                )
                try Task.checkCancellation()
                self.events = loaded
                self.isLoading = false
                
                let calendar = Calendar.current
                let today = calendar.startOfDay(for: Date())
                let rangeStart = calendar.startOfDay(for: start)
                let rangeEnd = calendar.startOfDay(for: end)
                
                if today >= rangeStart && today <= rangeEnd {
                    let todayString = DateFormatters.request.string(from: Date())
                    let todayEvents = loaded.filter { $0.day == todayString }
                    if !todayEvents.isEmpty {
                        self.widgetBridge.saveSchedule(todayEvents)
                    }
                }
            } catch is CancellationError {
                self.isLoading = false
            } catch HTTPError.cancelled {
                self.isLoading = false
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
    
    func refresh() async {
        let group = selectedGroup
        let subgroup = selectedSubgroup
        let englishGroup = selectedEnglishGroup
        let profileSubgroup = selectedProfileSubgroup
        let start = dateRange.start
        let end = dateRange.end
        
        do {
            let loaded = try await repository.getSchedule(
                group: group,
                subgroup: subgroup,
                englishGroup: englishGroup,
                profileSubgroup: profileSubgroup,
                start: start,
                end: end
            )
            events = loaded
            errorMessage = nil
            
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            let rangeStart = calendar.startOfDay(for: start)
            let rangeEnd = calendar.startOfDay(for: end)
            
            if today >= rangeStart && today <= rangeEnd {
                let todayString = DateFormatters.request.string(from: Date())
                let todayEvents = loaded.filter { $0.day == todayString }
                if !todayEvents.isEmpty {
                    widgetBridge.saveSchedule(todayEvents)
                }
            }
        } catch {
            errorMessage = localizedMessage(from: error)
        }
    }
    
    // MARK: - Derived for UI
    var eventsByDay: [String: [ScheduleEvent]] {
        Dictionary(grouping: events, by: { $0.day })
    }
    
    var sortedDays: [String] {
        let allDays = eventsByDay.keys.sorted()
        
        if settingsRepository.skipWeekends {
            return allDays.filter { day in
                guard let date = DateFormatters.request.date(from: day) else {
                    return true
                }
                let weekday = Calendar.current.component(.weekday, from: date)
                return weekday != 1 && weekday != 7
            }
        }
        
        return allDays
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
