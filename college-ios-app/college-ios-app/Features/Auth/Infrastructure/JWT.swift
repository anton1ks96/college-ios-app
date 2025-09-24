//
//  JWT.swift
//  college-ios-app
//
//  Created by pc on 24.09.2025.
//

import Foundation
import JWTDecode

struct JWT {
    static func exp(from token: String) throws -> Date? {
        let jwt = try JWTDecode.decode(jwt: token)
        return jwt.expiresAt
    }
}
