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
                
                let titleInfo = titleInfoForStreak(streakViewModel.streak?.currentStreak ?? 0)
                TitleBadgeView(info: titleInfo)
                    .padding(.top, 4)
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
                    .font(.subheadline.weight(.medium))
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(25)
            }
        }
        .padding(.vertical, 40)
    }
    
    private func titleInfoForStreak(_ count: Int) -> StreakTitleInfo {
        switch count {
        case 0:
            return StreakTitleInfo(title: "Прогульщик", color: .gray)
        case 1...2:
            return StreakTitleInfo(title: "Новичок КЦТ", color: .green)
        case 3...6:
            return StreakTitleInfo(title: "Студент КЦТ", color: .blue)
        case 7...13:
            return StreakTitleInfo(title: "Ветеран КЦТ", color: .purple)
        case 14...20:
            return StreakTitleInfo(title: "Мастер КЦТ", color: .pink)
        case 21...29:
            return StreakTitleInfo(title: "Элита КЦТ", color: .orange)
        case 30...49:
            return StreakTitleInfo(title: "Легенда КЦТ", color: Color(red: 0.95, green: 0.85, blue: 0.45))
        case 50...74:
            return StreakTitleInfo(title: "Король КЦТ", color: .orange)
        case 75...99:
            return StreakTitleInfo(title: "Император КЦТ", color: Color(red: 0.75, green: 0.82, blue: 0.92))
        default:
            return StreakTitleInfo(title: "Бог посещаемости", color: .yellow)
        }
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

// MARK: - Title Badge

private struct StreakTitleInfo {
    let title: String
    let color: Color
}

private struct TitleBadgeView: View {
    let info: StreakTitleInfo
    
    private var secondaryColor: Color {
        switch info.color {
        case .yellow: return .orange
        case .orange: return .yellow
        default: return .white 
        }
    }
    
    var body: some View {
        Text(info.title)
            .font(.subheadline.weight(.semibold))
            .foregroundColor(info.color)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                LinearGradient(
                    colors: [
                        info.color.opacity(0.2),
                        secondaryColor.opacity(0.15)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(
                            colors: [info.color, secondaryColor],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            )
            .cornerRadius(20)
    }
}

// MARK: - Previews

#Preview("Активный streak") {
    let vm = StreakViewModel(api: PreviewStreakAPI(streak: StreakResponse(
        currentStreak: 5,
        longestStreak: 12,
        totalDaysAttended: 45,
        totalSchoolDays: 52,
        attendanceRate: 0.865,
        lastAttendedDate: "2025-11-25",
        periodStart: "2025-09-01",
        periodEnd: "2025-11-25"
    )))
    return StreakDetailSheet()
        .environmentObject(vm)
        .task { await vm.loadStreak() }
}

#Preview("Нулевой streak") {
    let vm = StreakViewModel(api: PreviewStreakAPI(streak: StreakResponse(
        currentStreak: 0,
        longestStreak: 7,
        totalDaysAttended: 30,
        totalSchoolDays: 52,
        attendanceRate: 0.577,
        lastAttendedDate: "2025-11-20",
        periodStart: "2025-09-01",
        periodEnd: "2025-11-25"
    )))
    return StreakDetailSheet()
        .environmentObject(vm)
        .task { await vm.loadStreak() }
}

#Preview("Легенда КЦТ (30 дней)") {
    let vm = StreakViewModel(api: PreviewStreakAPI(streak: StreakResponse(
        currentStreak: 30,
        longestStreak: 30,
        totalDaysAttended: 52,
        totalSchoolDays: 52,
        attendanceRate: 1.0,
        lastAttendedDate: "2025-11-25",
        periodStart: "2025-09-01",
        periodEnd: "2025-11-25"
    )))
    return StreakDetailSheet()
        .environmentObject(vm)
        .task { await vm.loadStreak() }
}

#Preview("Король КЦТ (50-74 дня)") {
    let vm = StreakViewModel(api: PreviewStreakAPI(streak: StreakResponse(
        currentStreak: 60,
        longestStreak: 60,
        totalDaysAttended: 60,
        totalSchoolDays: 60,
        attendanceRate: 1.0,
        lastAttendedDate: "2025-11-25",
        periodStart: "2025-09-01",
        periodEnd: "2025-11-25"
    )))
    return StreakDetailSheet()
        .environmentObject(vm)
        .task { await vm.loadStreak() }
}

#Preview("Император КЦТ (75-99 дней)") {
    let vm = StreakViewModel(api: PreviewStreakAPI(streak: StreakResponse(
        currentStreak: 85,
        longestStreak: 85,
        totalDaysAttended: 85,
        totalSchoolDays: 85,
        attendanceRate: 1.0,
        lastAttendedDate: "2025-11-25",
        periodStart: "2025-09-01",
        periodEnd: "2025-11-25"
    )))
    return StreakDetailSheet()
        .environmentObject(vm)
        .task { await vm.loadStreak() }
}

#Preview("Бог посещаемости (100+ дней)") {
    let vm = StreakViewModel(api: PreviewStreakAPI(streak: StreakResponse(
        currentStreak: 120,
        longestStreak: 120,
        totalDaysAttended: 120,
        totalSchoolDays: 120,
        attendanceRate: 1.0,
        lastAttendedDate: "2025-11-25",
        periodStart: "2025-09-01",
        periodEnd: "2025-11-25"
    )))
    return StreakDetailSheet()
        .environmentObject(vm)
        .task { await vm.loadStreak() }
}

#Preview("Один день") {
    let vm = StreakViewModel(api: PreviewStreakAPI(streak: StreakResponse(
        currentStreak: 1,
        longestStreak: 1,
        totalDaysAttended: 1,
        totalSchoolDays: 1,
        attendanceRate: 1.0,
        lastAttendedDate: "2025-11-25",
        periodStart: "2025-11-25",
        periodEnd: "2025-11-25"
    )))
    return StreakDetailSheet()
        .environmentObject(vm)
        .task { await vm.loadStreak() }
}

#Preview("Без последнего визита") {
    let vm = StreakViewModel(api: PreviewStreakAPI(streak: StreakResponse(
        currentStreak: 3,
        longestStreak: 10,
        totalDaysAttended: 40,
        totalSchoolDays: 50,
        attendanceRate: 0.8,
        lastAttendedDate: nil,
        periodStart: "2025-09-01",
        periodEnd: "2025-11-25"
    )))
    return StreakDetailSheet()
        .environmentObject(vm)
        .task { await vm.loadStreak() }
}

#Preview("Загрузка") {
    let vm = StreakViewModel(api: PreviewStreakAPI(delay: 999))
    return StreakDetailSheet()
        .environmentObject(vm)
        .task { await vm.loadStreak() }
}

#Preview("Ошибка") {
    let vm = StreakViewModel(api: PreviewStreakAPI(shouldFail: true))
    return StreakDetailSheet()
        .environmentObject(vm)
        .task { await vm.loadStreak() }
}

// MARK: - Preview Helpers

private class PreviewStreakAPI: StreakAPIProtocol {
    let streak: StreakResponse?
    let shouldFail: Bool
    let delay: TimeInterval
    
    init(
        streak: StreakResponse? = nil,
        shouldFail: Bool = false,
        delay: TimeInterval = 0
    ) {
        self.streak = streak
        self.shouldFail = shouldFail
        self.delay = delay
    }
    
    func fetchStreak() async throws -> StreakResponse {
        if delay > 0 {
            try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        }
        if shouldFail {
            throw APIError.decodingFailed
        }
        return streak ?? StreakResponse(
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
