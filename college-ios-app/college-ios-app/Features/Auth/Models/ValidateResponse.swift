//
//  ValidateResponse.swift
//  college-ios-app
//
//  Created by pc on 17.10.2025.
//

import Foundation

public nonisolated struct ValidateResponse: Codable, Sendable {
    public let valid: Bool
    public let user: User?
}
