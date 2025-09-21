//
//  DayScheduleCard.swift
//  college-ios-app
//
//  Created by pc on 21.09.2025.
//

import SwiftUI

struct DayScheduleCard: View {
    let day: String
    let events: [ScheduleEvent]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(day)
                    .font(.title3.weight(.semibold))
                Spacer()
                Text("\(events.count) \(lessonsText(events.count))")
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
                ForEach(events) { event in
                    EventCard(event: event)
                }
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 12)
        }
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }

    private func lessonsText(_ count: Int) -> String {
        let lastDigit = count % 10
        let lastTwoDigits = count % 100

        if lastTwoDigits >= 11 && lastTwoDigits <= 14 {
            return "занятий"
        }

        switch lastDigit {
        case 1:
            return "занятие"
        case 2, 3, 4:
            return "занятия"
        default:
            return "занятий"
        }
    }
}
