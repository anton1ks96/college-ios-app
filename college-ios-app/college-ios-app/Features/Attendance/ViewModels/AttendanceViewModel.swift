//
//  AttendanceViewModel.swift
//  college-ios-app
//
//  Created by pc on 15.11.2025.
//

import Foundation
import SwiftUI
internal import Combine

@MainActor
final class AttendanceViewModel: ObservableObject {
    @Published var records: [AttendanceRecord] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var selectedWeekRange: (start: Date, end: Date)
    
    private let api: AttendanceAPIProtocol
    private var didInitialLoad = false
    
    init(api: AttendanceAPIProtocol) {
        self.api = api
        self.selectedWeekRange = Self.calculateCurrentWeekRange()
    }
    
    private static func calculateCurrentWeekRange() -> (start: Date, end: Date) {
        let calendar = Calendar.current
        let today = Date()
        
        guard let weekday = calendar.dateComponents([.weekday], from: today).weekday else {
            return (today, today)
        }
        
        let daysFromMonday = (weekday + 5) % 7
        guard let monday = calendar.date(byAdding: .day, value: -daysFromMonday, to: today),
              let sunday = calendar.date(byAdding: .day, value: 6, to: monday) else {
            return (today, today)
        }
        
        return (monday, sunday)
    }
    
    var currentWeekRange: (start: Date, end: Date) {
        Self.calculateCurrentWeekRange()
    }
    
    var isCurrentWeek: Bool {
        let calendar = Calendar.current
        let current = currentWeekRange
        return calendar.isDate(selectedWeekRange.start, inSameDayAs: current.start) &&
        calendar.isDate(selectedWeekRange.end, inSameDayAs: current.end)
    }
    
    var weekRangeText: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "d MMM"
        
        let startMonth = formatter.string(from: selectedWeekRange.start)
        formatter.dateFormat = "d MMM yyyy"
        let endFull = formatter.string(from: selectedWeekRange.end)
        
        return "\(startMonth) - \(endFull)"
    }
    
    func shiftWeek(by weeks: Int) {
        let calendar = Calendar.current
        guard let newStart = calendar.date(byAdding: .weekOfYear, value: weeks, to: selectedWeekRange.start),
              let newEnd = calendar.date(byAdding: .weekOfYear, value: weeks, to: selectedWeekRange.end) else {
            return
        }
        
        selectedWeekRange = (newStart, newEnd)
    }
    
    func goToCurrentWeek() {
        selectedWeekRange = currentWeekRange
    }
    
    // MARK: - Lifecycle hook
    func onAppearOnce() {
        guard !didInitialLoad else { return }
        didInitialLoad = true
        Task {
            await loadCurrentWeekAttendance()
        }
    }
    
    var groupedRecords: [(day: String, records: [AttendanceRecord])] {
        let grouped = Dictionary(grouping: records) { $0.day }
        return grouped
            .sorted { $0.key < $1.key }
            .map { (day: $0.key, records: $0.value.sorted { $0.start < $1.start }) }
    }
    
    var totalClasses: Int {
        records.count
    }
    
    var presentCount: Int {
        records.filter { $0.status == 2 }.count
    }
    
    var absentUnexcusedCount: Int {
        records.filter { $0.status == 0 }.count
    }
    
    var absentExcusedCount: Int {
        records.filter { $0.status == 1 }.count
    }
    
    var attendancePercentage: Double {
        guard totalClasses > 0 else { return 0 }
        return Double(presentCount) / Double(totalClasses) * 100
    }
    
    func loadCurrentWeekAttendance() async {
        await loadAttendance(start: selectedWeekRange.start, end: selectedWeekRange.end)
    }
    
    func loadAttendance(start: Date, end: Date) async {
        isLoading = true
        errorMessage = nil
        
        do {
            records = try await api.fetchAttendance(start: start, end: end)
            isLoading = false
        } catch let error as APIError {
            isLoading = false
            errorMessage = error.errorDescription
        } catch {
            isLoading = false
            errorMessage = "Не удалось загрузить данные о посещаемости"
        }
    }
    
    func refresh() async {
        await loadCurrentWeekAttendance()
    }
    
    func loadSelectedWeek() async {
        await loadAttendance(start: selectedWeekRange.start, end: selectedWeekRange.end)
    }
}
