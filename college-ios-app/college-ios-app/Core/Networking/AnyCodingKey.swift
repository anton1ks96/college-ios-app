//
//  AnyCodingKey.swift
//  college-ios-app
//

import Foundation

public nonisolated struct AnyCodingKey: CodingKey, Sendable {
    public let stringValue: String

    public var intValue: Int? { nil }

    public init(stringValue: String) {
        self.stringValue = stringValue
    }

    public init?(intValue: Int) {
        nil
    }
}
