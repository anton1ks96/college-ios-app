//
//  PerformanceSubjectScore.swift
//  college-ios-app
//
//  Created by pc on 19.11.2025.
//

import Foundation
import SwiftUI

nonisolated struct PerformanceScore: Decodable, Identifiable, Sendable {
    let id = UUID()
    let dateF: String?
    let dateP: String?
    let score: String
    let maxScore: Int
    let description: String
    
    enum CodingKeys: String, CodingKey {
        case dateF = "DateF"
        case dateP = "DateP"
        case score = "Score"
        case maxScore = "MaxScore"
        case description = "Description"
    }
    
    var isGraded: Bool {
        !score.isEmpty
    }
    
    var scoreValue: Int? {
        Int(score)
    }
    
    var formattedDate: String {
        guard let dateString = dateF ?? dateP else { return "—" }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        guard let date = formatter.date(from: dateString) else {
            return dateString
        }
        
        let outputFormatter = DateFormatter()
        outputFormatter.locale = Locale(identifier: "ru_RU")
        outputFormatter.dateFormat = "d MMM yyyy"
        return outputFormatter.string(from: date)
    }
    
    var scoreColor: Color {
        guard let value = scoreValue else { return .gray }
        
        if value >= 4 { return .green }
        if value >= 3 { return .orange }
        return .red
    }
    
    var progressPercentage: Double {
        guard let value = scoreValue, maxScore > 0 else { return 0 }
        return Double(value) / Double(maxScore)
    }
}
