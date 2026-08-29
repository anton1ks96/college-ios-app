//
//  Streak.swift
//  college-ios-app
//

import Foundation

nonisolated struct Streak: Equatable, Sendable {
    let current: Int
    let longest: Int
    let daysAttended: Int
    let schoolDays: Int
    let lastAttended: Date?
    let periodStart: Date?
    let periodEnd: Date?

    var rate: Double {
        schoolDays > 0 ? Double(daysAttended) * 100 / Double(schoolDays) : 0
    }
}
