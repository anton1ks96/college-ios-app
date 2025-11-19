//
//  StatisticsCard.swift
//  college-ios-app
//
//  Created by pc on 19.11.2025.
//

import SwiftUI

struct StatisticsCard: View {
    let statistics: SubjectDetailViewModel.Statistics
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Статистика")
                    .font(.headline)
                Spacer()
            }
            
            HStack(spacing: 12) {
                StatisticItem(
                    title: "Средний балл",
                    value: String(format: "%.1f", statistics.averageScore),
                    icon: "star.fill",
                    color: averageScoreColor
                )
                
                StatisticItem(
                    title: "Оценок",
                    value: "\(statistics.totalGraded)",
                    icon: "checkmark.circle.fill",
                    color: .blue
                )
                
                StatisticItem(
                    title: "Выполнение",
                    value: String(format: "%.0f%%", statistics.completionPercentage),
                    icon: "chart.bar.fill",
                    color: completionColor
                )
            }
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    private var averageScoreColor: Color {
        if statistics.averageScore >= 4.5 { return .green }
        if statistics.averageScore >= 3.5 { return .orange }
        return .red
    }
    
    private var completionColor: Color {
        if statistics.completionPercentage >= 80 { return .green }
        if statistics.completionPercentage >= 60 { return .orange }
        return .red
    }
}

struct StatisticItem: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
            
            Text(value)
                .font(.title2.weight(.bold))
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color(.tertiarySystemGroupedBackground))
        .cornerRadius(12)
    }
}
