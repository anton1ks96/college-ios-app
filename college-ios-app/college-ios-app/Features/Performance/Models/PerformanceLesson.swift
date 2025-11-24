//
//  PerformanceLesson.swift
//  college-ios-app
//
//  Created by pc on 19.11.2025.
//

import Foundation

struct PerformanceLesson: Identifiable, Sendable {
    let id = UUID()
    let lessonName: String
    let scores: [PerformanceScore]
    
    var allGraded: Bool {
        !scores.isEmpty && scores.allSatisfy { $0.isGraded }
    }
    
    var hasGradedScores: Bool {
        scores.contains { $0.isGraded }
    }
    
    var gradedScores: [PerformanceScore] {
        scores.filter { $0.isGraded }
    }
    
    var pendingScores: [PerformanceScore] {
        scores.filter { !$0.isGraded }
    }
}
