//
//  LessonScoreCard.swift
//  college-ios-app
//
//  Created by pc on 19.11.2025.
//

import SwiftUI

struct LessonScoreCard: View {
    let lesson: PerformanceLesson
    let showOnlyGraded: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(lesson.lessonName)
                    .font(.headline)
                Spacer()
            }
            
            VStack(spacing: 8) {
                ForEach(filteredScores) { score in
                    ScoreRow(score: score)
                }
            }
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    private var filteredScores: [PerformanceScore] {
        if showOnlyGraded {
            return lesson.gradedScores
        } else {
            return lesson.pendingScores
        }
    }
}

struct ScoreRow: View {
    let score: PerformanceScore
    
    var body: some View {
        HStack(spacing: 12) {
            if score.isGraded, let scoreValue = score.scoreValue {
                ZStack {
                    Circle()
                        .fill(score.scoreColor.opacity(0.1))
                        .frame(width: 44, height: 44)
                    
                    Text("\(scoreValue)")
                        .font(.title3.weight(.bold))
                        .foregroundColor(score.scoreColor)
                }
            } else {
                ZStack {
                    Circle()
                        .fill(Color.gray.opacity(0.1))
                        .frame(width: 44, height: 44)
                    
                    Text("—")
                        .font(.title3.weight(.bold))
                        .foregroundColor(.gray)
                }
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(score.description)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                
                Text(score.formattedDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if score.isGraded {
                Text("\(score.scoreValue ?? 0)/\(score.maxScore)")
                    .font(.caption.weight(.medium))
                    .foregroundColor(.secondary)
            } else {
                Text("макс: \(score.maxScore)")
                    .font(.caption.weight(.medium))
                    .foregroundColor(.secondary)
            }
        }
        .padding(12)
        .background(Color(.tertiarySystemGroupedBackground))
        .cornerRadius(12)
    }
}
