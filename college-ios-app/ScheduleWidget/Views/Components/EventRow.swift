//
//  EventRow.swift
//  ScheduleWidget
//
//  Created by pc on 03.10.2025.
//

import SwiftUI

struct EventRow: View {
    let event: ScheduleEvent
    let isFirst: Bool
    
    var body: some View {
        HStack(spacing: 10) {
            VStack(alignment: .trailing, spacing: 2) {
                Text(event.start)
                    .font(.system(size: 13, weight: isFirst ? .semibold : .regular))
                    .foregroundColor(isFirst ? Color("AccentColor") : .primary)
                
                Text(event.end)
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
            
            
            RoundedRectangle(cornerRadius: 1)
                .fill(isFirst ? Color("AccentColor") : Color.gray.opacity(0.3))
                .frame(width: 2)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(event.title)
                    .font(.system(size: 13, weight: isFirst ? .semibold : .medium))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                HStack(spacing: 6) {
                    Label(event.room, systemImage: "location.fill")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                    
                    if !event.topic.isEmpty {
                        Text("•")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                        
                        Text(event.topic)
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer(minLength: 0)
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isFirst ? Color("AccentColor").opacity(0.08) : Color.clear)
        )
    }
}
