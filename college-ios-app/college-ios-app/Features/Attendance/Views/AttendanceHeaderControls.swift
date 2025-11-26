//
//  AttendanceHeaderControls.swift
//  college-ios-app
//
//  Created by pc on 19.11.2025.
//

import SwiftUI

struct AttendanceHeaderControls: View {
    @ObservedObject var viewModel: AttendanceViewModel
    @State private var showDatePicker = false
    @State private var customStartDate = Date()
    @State private var customEndDate = Date()
    
    var body: some View {
        VStack(spacing: 12) {
            quickNavigationButtons
            
            dateRangeNavigation
        }
        .padding(.vertical, 12)
        .background(Color(.systemGroupedBackground))
        .sheet(isPresented: $showDatePicker) {
            datePickerSheet
        }
    }
    
    // MARK: - Quick Navigation Buttons
    
    private var quickNavigationButtons: some View {
        VStack(spacing: 8) {
            HStack {
                quickWeekButton(title: "Текущая неделя", weeksOffset: 0)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 2)
                
                quickWeekButton(title: "Прошлая неделя", weeksOffset: -1)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 2)
            }
            
            Button {
                customStartDate = viewModel.selectedWeekRange.start
                customEndDate = viewModel.selectedWeekRange.end
                showDatePicker = true
            } label: {
                Label("Выбрать", systemImage: "calendar")
                    .font(.subheadline.weight(.medium))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(12)
            }
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity)
    }
    
    
    @ViewBuilder
    private func quickWeekButton(title: String, weeksOffset: Int) -> some View {
        Button {
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            
            withAnimation(.easeInOut(duration: 0.2)) {
                if weeksOffset == 0 {
                    viewModel.goToCurrentWeek()
                } else {
                    let calendar = Calendar.current
                    let currentWeek = viewModel.currentWeekRange
                    if let targetStart = calendar.date(byAdding: .weekOfYear, value: weeksOffset, to: currentWeek.start),
                       let targetEnd = calendar.date(byAdding: .weekOfYear, value: weeksOffset, to: currentWeek.end) {
                        viewModel.updateWeekRange(start: targetStart, end: targetEnd)
                    }
                }
            }
            Task {
                await viewModel.loadSelectedWeek()
            }
        } label: {
            Text(title)
                .font(.subheadline.weight(.medium))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(
                    isSelectedWeek(weeksOffset)
                    ? Color.blue : Color(.tertiarySystemGroupedBackground)
                )
                .foregroundColor(isSelectedWeek(weeksOffset) ? .white : .primary)
                .cornerRadius(12)
        }
    }
    
    private func isSelectedWeek(_ weeksOffset: Int) -> Bool {
        let calendar = Calendar.current
        let currentWeek = viewModel.currentWeekRange
        
        if weeksOffset == 0 {
            return viewModel.isCurrentWeek
        }
        
        guard let targetStart = calendar.date(byAdding: .weekOfYear, value: weeksOffset, to: currentWeek.start),
              let targetEnd = calendar.date(byAdding: .weekOfYear, value: weeksOffset, to: currentWeek.end) else {
            return false
        }
        
        return calendar.isDate(viewModel.selectedWeekRange.start, inSameDayAs: targetStart) &&
        calendar.isDate(viewModel.selectedWeekRange.end, inSameDayAs: targetEnd)
    }
    
    // MARK: - Date Range Navigation
    
    private var dateRangeNavigation: some View {
        HStack {
            Button {
                let impact = UIImpactFeedbackGenerator(style: .light)
                impact.impactOccurred()
                
                withAnimation(.easeInOut(duration: 0.2)) {
                    viewModel.shiftWeek(by: -1)
                }
                Task {
                    await viewModel.loadSelectedWeek()
                }
            } label: {
                Image(systemName: "chevron.left.circle.fill")
                    .font(.system(size: 18))
                    .foregroundColor(.blue.opacity(0.8))
            }
            .buttonStyle(PlainButtonStyle())
            
            Image(systemName: "calendar.badge.clock")
                .font(.caption)
                .foregroundColor(.secondary)
            
            VStack(spacing: 2) {
                if !viewModel.isCurrentWeek && !viewModel.isPreviousWeek {
                    Text("Выбранная неделя")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                Text(viewModel.weekRangeText)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if viewModel.isLoadingWeek {
                ProgressView()
                    .scaleEffect(0.7)
            }
            
            Button {
                let impact = UIImpactFeedbackGenerator(style: .light)
                impact.impactOccurred()
                
                withAnimation(.easeInOut(duration: 0.2)) {
                    viewModel.shiftWeek(by: 1)
                }
                Task {
                    await viewModel.loadSelectedWeek()
                }
            } label: {
                Image(systemName: "chevron.right.circle.fill")
                    .font(.system(size: 18))
                    .foregroundColor(.blue.opacity(0.8))
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal)
    }
    
    // MARK: - Date Picker Sheet
    
    private var datePickerSheet: some View {
        NavigationStack {
            Form {
                Section {
                    DatePicker(
                        "Начало недели",
                        selection: $customStartDate,
                        displayedComponents: .date
                    )
                    
                    DatePicker(
                        "Конец недели",
                        selection: $customEndDate,
                        in: customStartDate...,
                        displayedComponents: .date
                    )
                }
            }
            .navigationTitle("Выбор периода")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") {
                        showDatePicker = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Применить") {
                        viewModel.updateWeekRange(start: customStartDate, end: customEndDate)
                        Task {
                            await viewModel.loadSelectedWeek()
                        }
                        showDatePicker = false
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}
