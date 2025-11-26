//
//  StreakDetailSheet.swift
//  college-ios-app
//
//  Created by pc on 24.11.2025.
//

import SwiftUI

struct StreakDetailSheet: View {
    @EnvironmentObject var streakViewModel: StreakViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    
                    if let streak = streakViewModel.streak {
                        statisticsSection(streak: streak)
                        periodSection(streak: streak)
                    } else if streakViewModel.isLoading {
                        loadingView
                    } else if let error = streakViewModel.errorMessage {
                        errorView(message: error)
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Посещаемость")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Готово") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDragIndicator(.visible)
    }
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.orange.opacity(0.2), .red.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                
                Image(systemName: "flame.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(
                        LinearGradient(
                            colors: (streakViewModel.streak?.currentStreak ?? 0) > 0
                            ? [.orange, .red]
                            : [.gray, .gray.opacity(0.7)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }
            
            VStack(spacing: 4) {
                Text("\(streakViewModel.streak?.currentStreak ?? 0)")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Text(daysText(streakViewModel.streak?.currentStreak ?? 0))
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical)
    }
    
    private func statisticsSection(streak: StreakResponse) -> some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                StatCard(
                    title: "Рекорд",
                    value: "\(streak.longestStreak)",
                    icon: "trophy.fill",
                    color: .yellow
                )
                
                StatCard(
                    title: "Посещено",
                    value: "\(streak.totalDaysAttended)/\(streak.totalSchoolDays)",
                    icon: "checkmark.circle.fill",
                    color: .green
                )
            }
            
            HStack(spacing: 12) {
                StatCard(
                    title: "Процент",
                    value: String(format: "%.0f%%", streak.attendanceRate * 100),
                    icon: "chart.pie.fill",
                    color: .blue
                )
                
                if let lastDate = streak.lastAttendedDate, !lastDate.isEmpty {
                    StatCard(
                        title: "Последний визит",
                        value: formatDate(lastDate),
                        icon: "calendar",
                        color: .purple
                    )
                }
            }
        }
    }
    
    private func periodSection(streak: StreakResponse) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Период")
                .font(.headline)
                .foregroundColor(.secondary)
            
            HStack {
                Image(systemName: "calendar.badge.clock")
                    .foregroundColor(.accentColor)
                
                Text("\(formatDate(streak.periodStart)) - \(formatDate(streak.periodEnd))")
                    .font(.subheadline)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.secondarySystemGroupedBackground))
            .cornerRadius(12)
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            Text("Загрузка...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 40)
    }
    
    private func errorView(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 40))
                .foregroundColor(.orange)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button {
                Task {
                    await streakViewModel.refresh()
                }
            } label: {
                Label("Повторить", systemImage: "arrow.clockwise")
            }
            .buttonStyle(.bordered)
        }
        .padding(.vertical, 40)
    }
    
    private func daysText(_ count: Int) -> String {
        let lastDigit = count % 10
        let lastTwoDigits = count % 100
        
        if lastTwoDigits >= 11 && lastTwoDigits <= 19 {
            return "дней подряд"
        }
        
        switch lastDigit {
        case 1:
            return "день подряд"
        case 2, 3, 4:
            return "дня подряд"
        default:
            return "дней подряд"
        }
    }
    
    private func formatDate(_ dateString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        
        guard let date = inputFormatter.date(from: dateString) else {
            return dateString
        }
        
        let outputFormatter = DateFormatter()
        outputFormatter.locale = Locale(identifier: "ru_RU")
        outputFormatter.dateFormat = "d MMM"
        
        return outputFormatter.string(from: date)
    }
}

private struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(value)
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
}

#Preview {
    StreakDetailSheet()
        .environmentObject(StreakViewModel(api: PreviewStreakAPI()))
}

private class PreviewStreakAPI: StreakAPIProtocol {
    func fetchStreak() async throws -> StreakResponse {
        StreakResponse(
            currentStreak: 5,
            longestStreak: 12,
            totalDaysAttended: 45,
            totalSchoolDays: 52,
            attendanceRate: 0.865,
            lastAttendedDate: "2025-11-25",
            periodStart: "2025-09-01",
            periodEnd: "2025-11-25"
        )
    }
}
