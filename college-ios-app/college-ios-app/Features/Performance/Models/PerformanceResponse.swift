//
//  PerformanceResponse.swift
//  college-ios-app
//
//  Created by pc on 19.11.2025.
//

import Foundation

struct PerformanceResponse: Decodable {
    let lessons: [PerformanceLesson]
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let dict = try container.decode([String: [String: [PerformanceScore]]].self)
        
        guard let subjectDict = dict.values.first else {
            self.lessons = []
            return
        }
        
        self.lessons = subjectDict.map { (lessonName, scores) in
            PerformanceLesson(lessonName: lessonName, scores: scores)
        }
        .sorted { $0.lessonName < $1.lessonName } 
    }
}
