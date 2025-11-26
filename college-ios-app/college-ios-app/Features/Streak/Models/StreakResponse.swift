//
//  StreakResponse.swift
//  college-ios-app
//
//  Created by pc on 24.11.2025.
//

import Foundation

struct StreakResponse: Decodable, Sendable {
    let currentStreak: Int
    let longestStreak: Int
    let totalDaysAttended: Int
    let totalSchoolDays: Int
    let attendanceRate: Double
    let lastAttendedDate: String?
    let periodStart: String
    let periodEnd: String
    
    enum CodingKeys: String, CodingKey {
        case currentStreak = "current_streak"
        case longestStreak = "longest_streak"
        case totalDaysAttended = "total_days_attended"
        case totalSchoolDays = "total_school_days"
        case attendanceRate = "attendance_rate"
        case lastAttendedDate = "last_attended_date"
        case periodStart = "period_start"
        case periodEnd = "period_end"
    }
}
