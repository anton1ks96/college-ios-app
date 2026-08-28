//
//  AttendanceRecord.swift
//  college-ios-app
//
//  Created by pc on 15.11.2025.
//

import Foundation
import SwiftUI

nonisolated struct AttendanceRecord: Decodable, Identifiable {
    let id = UUID()
    let clID: Int
    let day: String
    let topic: String?
    let start: String
    let end: String
    let room: String
    let status: Int
    let title: String
    let color: String
    let type: String?
    
    enum CodingKeys: String, CodingKey {
        case clID = "ClID"
        case day = "Day"
        case topic
        case start
        case end
        case room
        case status
        case title
        case color
        case type
    }
    
    var statusText: String {
        switch status {
        case 0: return "Не был (Н/У)"
        case 1: return "Не был (Ув.)"
        case 2: return "Был"
        default: return "Неизвестно"
        }
    }
    
    var statusIcon: String {
        switch status {
        case 0: return "xmark.circle.fill"
        case 1: return "exclamationmark.circle.fill"
        case 2: return "checkmark.circle.fill"
        default: return "questionmark.circle.fill"
        }
    }
    
    var statusColor: Color {
        switch status {
        case 0: return .red
        case 1: return .yellow
        case 2: return .green
        default: return .gray
        }
    }
    
    var dayDate: Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: day)
    }
    
    var formattedDayHeader: String {
        guard let date = dayDate else { return day }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "EEEE, d MMMM"
        return formatter.string(from: date).capitalized
    }
    
    var timeRange: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        guard let startDate = formatter.date(from: start),
              let endDate = formatter.date(from: end) else {
            return ""
        }
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        
        return "\(timeFormatter.string(from: startDate)) - \(timeFormatter.string(from: endDate))"
    }
}
