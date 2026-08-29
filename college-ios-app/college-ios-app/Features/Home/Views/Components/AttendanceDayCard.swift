//
//  AttendanceDayCard.swift
//  college-ios-app
//

import SwiftUI

struct AttendanceDayCard: View {
    @Environment(\.colors) private var colors

    let day: AttendanceDay
    let isToday: Bool

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: Metrics.cardRadius, style: .continuous)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            DayHeader(
                date: day.date,
                detail: "\(day.present) из \(day.records.count)",
                isToday: isToday
            )

            rows
        }
    }

    private var rows: some View {
        VStack(spacing: 0) {
            ForEach(Array(day.records.enumerated()), id: \.element.id) { index, record in
                if index > 0 {
                    Rectangle()
                        .fill(colors.onSurface.opacity(0.06))
                        .frame(height: 1)
                        .padding(.leading, 64)
                }

                AttendanceRow(record: record)
            }
        }
        .clipShape(shape)
        .glassSurface(shape)
    }
}

#Preview {
    let monday = ScheduleCalendar.monday(of: .now)

    return ScrollView {
        VStack(spacing: 20) {
            ForEach(HomeParsing.days(from: HomeMocks.records(monday: monday))) { day in
                AttendanceDayCard(day: day, isToday: day.date == ScheduleCalendar.day(of: .now))
            }
        }
        .padding(16)
    }
    .appBackground()
    .environment(\.colors, .dark)
}
