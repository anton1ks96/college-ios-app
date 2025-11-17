//
//  AttendanceRecordCard.swift
//  college-ios-app
//
//  Created by pc on 14.11.2025.
//

import SwiftUI

struct AttendanceRecordCard: View {
    let record: AttendanceRecord
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(spacing: 4) {
                Text(record.timeRange.components(separatedBy: " - ").first ?? "")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                Text(record.timeRange.components(separatedBy: " - ").last ?? "")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
            }
            .frame(width: 50)
            
            Image(systemName: record.statusIcon)
                .font(.system(size: 20))
                .foregroundColor(record.statusColor)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(record.title)
                    .font(.system(size: 15, weight: .medium))
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                
                if let topic = record.topic, !topic.isEmpty {
                    Text(topic)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                HStack(spacing: 12) {
                    if !record.room.isEmpty {
                        Label(record.room, systemImage: "location.fill")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color(.tertiarySystemFill))
                            .cornerRadius(6)
                    }
                    
                    Text(record.statusText)
                        .font(.caption.weight(.medium))
                        .foregroundColor(record.statusColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(record.statusColor.opacity(0.1))
                        .cornerRadius(6)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(12)
        .background(Color(.tertiarySystemGroupedBackground))
        .cornerRadius(12)
    }
}

struct StatisticBox: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            Text(value)
                .font(.title2.weight(.bold))
                .foregroundColor(color)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}
