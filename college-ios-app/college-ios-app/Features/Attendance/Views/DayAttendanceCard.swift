//
//  DayAttendanceCard.swift
//  college-ios-app
//
//  Created by pc on 14.11.2025.
//

import SwiftUI

struct DayAttendanceCard: View {
    let day: String
    let records: [AttendanceRecord]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(day)
                    .font(.title3.weight(.semibold))
                Spacer()
                Text("\(records.count) \(TextLessons.lessons(records.count))")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color(.tertiarySystemGroupedBackground))
                    .cornerRadius(12)
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            
            VStack(spacing: 8) {
                ForEach(records) { record in
                    AttendanceRecordCard(record: record)
                }
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 12)
        }
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }
}
