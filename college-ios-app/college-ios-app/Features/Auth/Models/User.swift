//
//  User.swift
//  college-ios-app
//
//  Created by pc on 17.10.2025.
//

import Foundation

public struct User: Codable, Equatable, Sendable {
    public let id: String
    public let username: String
    public let role: String?
    public let academicGroup: String?
    public let profile: String?

    enum CodingKeys: String, CodingKey {
        case id, username, role
        case academicGroup = "academic_group"
        case profile
    }
}
