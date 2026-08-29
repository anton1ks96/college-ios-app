//
//  Performance.swift
//  college-ios-app
//

import Foundation

nonisolated struct Subject: Identifiable, Equatable, Sendable {
    let id: String
    let title: String
}

nonisolated struct Score: Identifiable, Equatable, Sendable {
    let id: String
    let date: Date?
    let value: Int?
    let max: Int
    let details: String

    var share: Double? {
        guard let value, max > 0 else { return nil }
        return Double(value) / Double(max)
    }
}

nonisolated struct SubjectLesson: Identifiable, Equatable, Sendable {
    let title: String
    let scores: [Score]

    var id: String { title }
}
