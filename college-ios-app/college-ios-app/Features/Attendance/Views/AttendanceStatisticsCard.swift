//
//  AttendanceStatisticsCard.swift
//  college-ios-app
//
//  Created by pc on 19.11.2025.
//

import SwiftUI

struct AttendanceStatisticsCard: View {
    @ObservedObject var viewModel: AttendanceViewModel
    
    var body: some View {
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
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}
