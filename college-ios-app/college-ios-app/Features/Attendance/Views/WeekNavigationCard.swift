//
//  WeekNavigationCard.swift
//  college-ios-app
//
//  Created by pc on 16.11.2025.
//

import SwiftUI

struct WeekNavigationCard: View {
    @ObservedObject var viewModel: AttendanceViewModel
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "calendar")
                    .font(.title3)
                    .foregroundColor(Color("AccentColor"))
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(viewModel.isCurrentWeek ? "Текущая неделя" : "Неделя")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(viewModel.weekRangeText)
                        .font(.headline)
                }
                
                Spacer()
                
                if !viewModel.isCurrentWeek {
                    Button {
                        viewModel.goToCurrentWeek()
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
            
            HStack {
                Button {
                    viewModel.shiftWeek(by: -1)
                    Task {
                        await viewModel.loadSelectedWeek()
                    }
                } label: {
                    Image(systemName: "chevron.left.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(Color("AccentColor").opacity(0.8))
                }
                
                Spacer()
                
                Text("Неделя с \(DateFormatters.uiDate.string(from: viewModel.selectedWeekRange.start)) по \(DateFormatters.uiDate.string(from: viewModel.selectedWeekRange.end))")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button {
                    viewModel.shiftWeek(by: 1)
                    Task {
                        await viewModel.loadSelectedWeek()
                    }
                } label: {
                    Image(systemName: "chevron.right.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(Color("AccentColor").opacity(0.8))
                }
            }
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }
}
