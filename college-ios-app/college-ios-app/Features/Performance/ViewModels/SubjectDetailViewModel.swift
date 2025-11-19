//
//  SubjectDetailViewModel.swift
//  college-ios-app
//
//  Created by pc on 19.11.2025.
//

import Foundation
import SwiftUI
internal import Combine

@MainActor
final class SubjectDetailViewModel: ObservableObject {
    @Published var lessons: [PerformanceLesson] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let api: PerformanceAPIProtocol
    private var didInitialLoad = false
    
    let subject: PerformanceSubject
    
    init(api: PerformanceAPIProtocol, subject: PerformanceSubject) {
        self.api = api
        self.subject = subject
    }
    
    // MARK: - Lifecycle
    
    func onAppearOnce() {
        guard !didInitialLoad else { return }
        didInitialLoad = true
        Task {
            await loadScores()
        }
    }
    
    // MARK: - Data Loading
    
    func loadScores() async {
        isLoading = true
        errorMessage = nil
        
        let dateRange = Date().currentSemesterDateRange
        
        do {
            lessons = try await api.fetchScores(
                suID: subject.suID,
                start: dateRange.start,
                end: dateRange.end
            )
            isLoading = false
        } catch let error as APIError {
            isLoading = false
            errorMessage = error.errorDescription
        } catch {
            isLoading = false
            errorMessage = "Не удалось загрузить оценки"
        }
    }
    
    func refresh() async {
        await loadScores()
    }
    
    // MARK: - Computed Properties
    
    var allScores: [PerformanceScore] {
        lessons.flatMap { $0.scores }
    }
    
    var gradedScores: [PerformanceScore] {
        allScores.filter { $0.isGraded }
    }
    
    var pendingScores: [PerformanceScore] {
        allScores.filter { !$0.isGraded }
    }
    
    var lessonsWithGradedScores: [PerformanceLesson] {
        lessons.filter { $0.hasGradedScores }
    }
    
    var lessonsWithPendingScores: [PerformanceLesson] {
        lessons.filter { !$0.pendingScores.isEmpty }
    }
    
    // MARK: - Statistics
    
    struct Statistics {
        let averageScore: Double
        let totalGraded: Int
        let completionPercentage: Double
    }
    
    var statistics: Statistics {
        let graded = gradedScores
        
        guard !graded.isEmpty else {
            return Statistics(averageScore: 0, totalGraded: 0, completionPercentage: 0)
        }
        
        let totalScore = graded.compactMap { $0.scoreValue }.reduce(0, +)
        let averageScore = Double(totalScore) / Double(graded.count)
        
        let earnedPoints = graded.compactMap { $0.scoreValue }.reduce(0, +)
        let maxPoints = graded.map { $0.maxScore }.reduce(0, +)
        let completionPercentage = maxPoints > 0 ? (Double(earnedPoints) / Double(maxPoints)) * 100 : 0
        
        return Statistics(
            averageScore: averageScore,
            totalGraded: graded.count,
            completionPercentage: completionPercentage
        )
    }
}
