//
//  ValidateResponse.swift
//  college-ios-app
//
//  Created by pc on 17.10.2025.
//

import Foundation

public struct ValidateResponse: Codable, Sendable {
    public let valid: Bool
    public let user: User?
}
