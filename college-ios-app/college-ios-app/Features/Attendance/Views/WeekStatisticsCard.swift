//
//  WeekStatisticsCard.swift
//  college-ios-app
//
//  Created by pc on 16.11.2025.
//

import SwiftUI

struct WeekStatisticsCard: View {
    @ObservedObject var viewModel: AttendanceViewModel
    @State private var showDatePicker = false
    @State private var customStartDate = Date()
    @State private var customEndDate = Date()
    
    var body: some View {
        VStack(spacing: 0) {
            navigationSection
            
            Divider()
                .padding(.vertical, 12)
            
            statisticsSection
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        .sheet(isPresented: $showDatePicker) {
            datePickerSheet
        }
    }
    
    // MARK: - Navigation Section
    
    private var navigationSection: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "calendar")
                    .font(.title3)
                    .foregroundColor(Color("AccentColor"))
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(viewModel.isCurrentWeek ? "Текущая неделя" : "Выбранная неделя")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 6) {
                        Text(viewModel.weekRangeText)
                            .font(.headline)
                        
                        if viewModel.isLoadingWeek {
                            ProgressView()
                                .scaleEffect(0.7)
                                .frame(width: 16, height: 16)
                        }
                    }
                }
                
                Spacer()
                
                if !viewModel.isCurrentWeek {
                    Button {
                        let impact = UIImpactFeedbackGenerator(style: .light)
                        impact.impactOccurred()
                        
                        withAnimation(.easeInOut(duration: 0.2)) {
                            viewModel.goToCurrentWeek()
                        }
                        Task {
                            await viewModel.loadSelectedWeek()
                        }
                    } label: {
                        Text("Сегодня")
                            .font(.caption.weight(.medium))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(12)
                    }
                }
            }
            
            HStack(spacing: 20) {
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
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Назад")
                            .font(.subheadline.weight(.medium))
                    }
                    .foregroundColor(Color("AccentColor"))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color("AccentColor").opacity(0.1))
                    .cornerRadius(10)
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
                
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
                    HStack(spacing: 6) {
                        Text("Вперед")
                            .font(.subheadline.weight(.medium))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(Color("AccentColor"))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color("AccentColor").opacity(0.1))
                    .cornerRadius(10)
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            Button {
                customStartDate = viewModel.selectedWeekRange.start
                customEndDate = viewModel.selectedWeekRange.end
                showDatePicker = true
            } label: {
                HStack {
                    Image(systemName: "calendar")
                        .font(.subheadline)
                    Text("Выбрать период")
                        .font(.subheadline.weight(.medium))
                }
                .foregroundColor(.blue)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(10)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    // MARK: - Statistics Section
    
    private var statisticsSection: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .foregroundColor(Color("AccentColor"))
                Text("Статистика за период")
                    .font(.headline)
                Spacer()
            }
            
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    StatisticBox(
                        title: "Посещаемость",
                        value: String(format: "%.1f%%", viewModel.attendancePercentage),
                        color: viewModel.attendancePercentage >= 80 ? .green : (viewModel.attendancePercentage >= 60 ? .orange : .red)
                    )
                    
                    StatisticBox(
                        title: "Присутствовал",
                        value: "\(viewModel.presentCount)",
                        color: .green
                    )
                }
                
                HStack(spacing: 12) {
                    StatisticBox(
                        title: "Пропуски (н/у)",
                        value: "\(viewModel.absentUnexcusedCount)",
                        color: .red
                    )
                    
                    StatisticBox(
                        title: "Пропуски (ув.)",
                        value: "\(viewModel.absentExcusedCount)",
                        color: .yellow
                    )
                }
            }
            .opacity(viewModel.isLoadingWeek ? 0.6 : 1.0)
            .animation(.easeInOut(duration: 0.3), value: viewModel.isLoadingWeek)
        }
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
