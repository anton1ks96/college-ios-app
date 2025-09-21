//
//  ScheduleSubGroup.swift
//  college-ios-app
//
//  Created by pc on 21.09.2025.
//

import Foundation

struct ScheduleSubGroup: Decodable, Identifiable {
    let id = UUID()
    let sClID: String
    let sGrID: String
    let sGCaID: String
    let sTopic: String
    let sTitle: String

    enum CodingKeys: String, CodingKey {
        case sClID = "SClID"
        case sGrID = "SGrID"
        case sGCaID = "SGCaID"
        case sTopic = "STopic"
        case sTitle = "STitle"
    }
}
