//
//  ErrorStateView.swift
//  ScheduleWidget
//
//  Created by pc on 12.11.2025.
//

import SwiftUI
import WidgetKit

struct ErrorStateView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 40))
                .foregroundColor(.orange)
            
            Text("Не удалось загрузить расписание")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            Link(destination: URL(string: "college-ios-app://")!) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("Обновить")
                }
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color("AccentColor"))
                .foregroundColor(.white)
                .cornerRadius(8)
            }
        }
        .padding()
    }
}

#Preview {
    ErrorStateView()
}
