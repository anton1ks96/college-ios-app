//
//  SemesterUtils.swift
//  college-ios-app
//
//  Created by pc on 19.11.2025.
//

import Foundation

enum Semester {
    case first
    case second
    
    var displayName: String {
        switch self {
        case .first: return "1 полугодие"
        case .second: return "2 полугодие"
        }
    }
    
    func dateRange(for year: Int) -> (start: Date, end: Date) {
        let calendar = Calendar.current
        switch self {
        case .first:
            let start = calendar.date(from: DateComponents(year: year, month: 1, day: 1))!
            let end = calendar.date(from: DateComponents(year: year, month: 6, day: 30))!
            return (start, end)
        case .second:
            let start = calendar.date(from: DateComponents(year: year, month: 9, day: 1))!
            let end = calendar.date(from: DateComponents(year: year, month: 12, day: 31))!
            return (start, end)
        }
    }
}

extension Date {
    var currentSemester: Semester {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: self)
        
        if (1...6).contains(month) {
            return .first
        }
        else if (9...12).contains(month) {
            return .second
        }
        else {
            return .second
        }
    }
    
    var currentSemesterDateRange: (start: Date, end: Date) {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: self)
        return currentSemester.dateRange(for: year)
    }
}
