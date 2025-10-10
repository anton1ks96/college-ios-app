//
//  ScheduleView.swift
//  college-ios-app
//
//  Created by pc on 21.09.2025.
//

import SwiftUI

struct ScheduleView: View {
    @ObservedObject var viewModel: ScheduleViewModel
    @State private var showDatePicker = false
    @State private var customStartDate = Date()
    @State private var customEndDate = Date()
    @State private var showGroupPicker = false
    @State private var showSubgroupPicker = false
    
    var body: some View {
        VStack(spacing: 0) {
            headerControls
            
            if viewModel.isLoading {
                loadingView
            } else if let error = viewModel.errorMessage {
                errorView(message: error)
            } else if viewModel.events.isEmpty {
                emptyStateView
            } else {
                scheduleContent
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Расписание")
        .navigationBarTitleDisplayMode(.large)
        .task {
            viewModel.onAppearOnce()
        }
        .sheet(isPresented: $showDatePicker) {
            datePickerSheet
        }
        .sheet(isPresented: $showGroupPicker) {
            groupPickerSheet
        }
        .sheet(isPresented: $showSubgroupPicker) {
            subgroupPickerSheet
        }
    }
    
    private var headerControls: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                Button {
                    showGroupPicker = true
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Группа")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(viewModel.selectedGroup)
                                .font(.headline)
                        }
                        Spacer()
                        Image(systemName: "chevron.down")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color(.secondarySystemGroupedBackground))
                    .cornerRadius(12)
                }
                .foregroundColor(.primary)
                
                Button {
                    showSubgroupPicker = true
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Подгруппа")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(
                                viewModel.selectedSubgroup == "*"
                                ? "Все" : viewModel.selectedSubgroup
                            )
                            .font(.headline)
                        }
                        Spacer()
                        Image(systemName: "chevron.down")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color(.secondarySystemGroupedBackground))
                    .cornerRadius(12)
                }
                .foregroundColor(.primary)
            }
            .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    quickDateButton(title: "Сегодня", days: 0)
                    quickDateButton(title: "3 дня", days: 2)
                    quickDateButton(title: "Неделя", days: 6)
                    
                    Button {
                        customStartDate = viewModel.dateRange.start
                        customEndDate = viewModel.dateRange.end
                        showDatePicker = true
                    } label: {
                        Label("Выбрать", systemImage: "calendar")
                            .font(.subheadline.weight(.medium))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(20)
                    }
                }
                .padding(.horizontal)
            }
            
            HStack {
                Button {
                    viewModel.shiftDateRange(by: -1)
                    viewModel.loadSchedule()
                } label: {
                    Image(systemName: "chevron.left.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.blue.opacity(0.8))
                }
                
                Image(systemName: "calendar.badge.clock")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(
                    "\(DateFormatters.uiDate.string(from: viewModel.dateRange.start)) — \(DateFormatters.uiDate.string(from: viewModel.dateRange.end))"
                )
                .font(.caption)
                .foregroundColor(.secondary)
                
                Button {
                    viewModel.shiftDateRange(by: 1)
                    viewModel.loadSchedule()
                } label: {
                    Image(systemName: "chevron.right.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.blue.opacity(0.8))
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 12)
        .background(Color(.systemGroupedBackground))
    }
    
    private func quickDateButton(title: String, days: Int) -> some View {
        Button {
            viewModel.setQuickRange(daysFromToday: days)
            viewModel.loadSchedule()
        } label: {
            Text(title)
                .font(.subheadline.weight(.medium))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    isCurrentRange(days: days)
                    ? Color.blue : Color(.tertiarySystemGroupedBackground)
                )
                .foregroundColor(isCurrentRange(days: days) ? .white : .primary)
                .cornerRadius(20)
        }
    }
    
    private func isCurrentRange(days: Int) -> Bool {
        let calendar = Calendar.current
        let expectedRange = viewModel.calculateQuickRange(daysFromToday: days)
        return calendar.isDate(
            viewModel.dateRange.start,
            inSameDayAs: expectedRange.start
        )
        && calendar.isDate(
            viewModel.dateRange.end,
            inSameDayAs: expectedRange.end
        )
    }
    
    private var scheduleContent: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.sortedDays, id: \.self) { day in
                    if let events = viewModel.eventsByDay[day] {
                        DayScheduleCard(
                            day: viewModel.formattedDay(day),
                            events: events
                        )
                    }
                }
            }
            .padding()
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            Text("Загрузка расписания...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func errorView(message: String) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 50))
                .foregroundColor(.orange)
            
            VStack(spacing: 8) {
                Text("Ошибка загрузки")
                    .font(.headline)
                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button {
                viewModel.retry()
            } label: {
                Label("Повторить", systemImage: "arrow.clockwise")
                    .font(.subheadline.weight(.medium))
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(25)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                Text("Нет занятий")
                    .font(.headline)
                Text("На выбранные даты занятия не найдены")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button {
                viewModel.setQuickRange(daysFromToday: 6)
                viewModel.loadSchedule()
            } label: {
                Label("Показать неделю", systemImage: "calendar")
                    .font(.subheadline.weight(.medium))
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(25)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var datePickerSheet: some View {
        NavigationStack {
            Form {
                Section {
                    DatePicker(
                        "Начало",
                        selection: $customStartDate,
                        displayedComponents: .date
                    )
                    
                    DatePicker(
                        "Конец",
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
                        viewModel.updateDateRange(
                            start: customStartDate,
                            end: customEndDate
                        )
                        viewModel.loadSchedule()
                        showDatePicker = false
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    private var groupPickerSheet: some View {
        NavigationStack {
            List {
                ForEach(GroupsCatalog.allGroups, id: \.self) { group in
                    Button {
                        viewModel.updateGroup(group)
                        viewModel.loadSchedule()
                        showGroupPicker = false
                    } label: {
                        HStack {
                            Text(group)
                                .foregroundColor(.primary)
                            Spacer()
                            if group == viewModel.selectedGroup {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Выбор группы")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") {
                        showGroupPicker = false
                    }
                }
            }
        }
    }
    
    private var subgroupPickerSheet: some View {
        NavigationStack {
            Form {
                Section(header: Text("Подгруппа")) {
                    ForEach(
                        viewModel.availableSubgroups.filter {
                            !isEnglishGroup($0)
                        },
                        id: \.self
                    ) { subgroup in
                        Button {
                            viewModel.updateSubgroup(subgroup)
                        } label: {
                            HStack {
                                Text(formatSubgroupName(subgroup))
                                    .foregroundColor(.primary)
                                Spacer()
                                if subgroup == viewModel.selectedSubgroup {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                }
                
                if viewModel.isEnglishGroupSelectionEnabled {
                    Section(header: Text("Группа английского")) {
                        ForEach(
                            ["*"] + viewModel.availableEnglishGroups,
                            id: \.self
                        ) { englishGroup in
                            Button {
                                viewModel.updateEnglishGroup(englishGroup)
                            } label: {
                                HStack {
                                    Text(
                                        englishGroup == "*"
                                        ? "Все" : englishGroup
                                    )
                                    .foregroundColor(.primary)
                                    Spacer()
                                    if englishGroup
                                        == viewModel.selectedEnglishGroup
                                    {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.blue)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Выбор подгруппы")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") {
                        showSubgroupPicker = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Применить") {
                        viewModel.loadSchedule()
                        showSubgroupPicker = false
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    private func isEnglishGroup(_ subgroup: String) -> Bool {
        let regex = try? NSRegularExpression(
            pattern: "^(A0|A1|A2|B1)\\.\\d{2}$"
        )
        let range = NSRange(subgroup.startIndex..., in: subgroup)
        return regex?.firstMatch(in: subgroup, range: range) != nil
    }
}

private func formatSubgroupName(_ subgroup: String) -> String {
    switch subgroup {
    case "*":
        return "Вся группа"
    case "Подгр1", "Подгр2", "Подгр3", "Подгр4":
        if let number = subgroup.last {
            return "Подгруппа \(number)"
        }
        return subgroup
    default:
        if GroupTypeFormatter.isKnownGroupType(subgroup) {
            return "\(GroupTypeFormatter.format(subgroup)) (\(subgroup))"
        }
        return subgroup
    }
}

#Preview("С расписанием") {
    NavigationStack {
        ScheduleView(viewModel: PreviewMocks.scheduleViewModelWithData)
    }
}

#Preview("Загрузка") {
    NavigationStack {
        ScheduleView(viewModel: PreviewMocks.scheduleViewModelLoading)
    }
}

#Preview("Ошибка") {
    NavigationStack {
        ScheduleView(viewModel: PreviewMocks.scheduleViewModelError)
    }
}

#Preview("Пустое расписание") {
    NavigationStack {
        ScheduleView(viewModel: PreviewMocks.scheduleViewModelEmpty)
    }
}
