//
//  AuthEvent.swift
//  college-ios-app
//
//  Created by pc on 23.08.2026.
//

import Foundation

public nonisolated enum SignOutReason: Sendable, Equatable {
    case userInitiated
    case sessionExpired
}

public nonisolated enum AuthEvent: Sendable, Equatable {
    case signedOut(SignOutReason)
}
