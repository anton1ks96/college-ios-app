//
//  SubjectCard.swift
//  college-ios-app
//
//  Created by pc on 19.11.2025.
//

import SwiftUI

struct SubjectCard: View {
    let subject: PerformanceSubject
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color("AccentColor").opacity(0.1))
                    .frame(width: 50, height: 50)
                
                Image(systemName: "book.fill")
                    .font(.system(size: 20))
                    .foregroundColor(Color("AccentColor"))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(subject.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                
                Text(subject.suID)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.secondary)
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}
