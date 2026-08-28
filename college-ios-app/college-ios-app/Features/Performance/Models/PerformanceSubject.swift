//
//  PerformanceSubject.swift
//  college-ios-app
//
//  Created by pc on 19.11.2025.
//

import Foundation

nonisolated struct PerformanceSubject: Decodable, Identifiable, Sendable {
    let id = UUID()
    let suIDcrc: String
    let suID: String
    let title: String
    
    enum CodingKeys: String, CodingKey {
        case suIDcrc = "SuIDcrc"
        case suID = "SuID"
        case title = "Title"
    }
}
