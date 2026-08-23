//
//  Keychain.swift
//  college-ios-app
//
//  Created by pc on 17.10.2025.
//

import Foundation
import Security

public nonisolated struct StoredRefreshToken: Codable, Sendable {
    public let token: String
    public let expiresAt: Date?

    public init(token: String, expiresAt: Date?) {
        self.token = token
        self.expiresAt = expiresAt
    }
}

public nonisolated protocol RefreshTokenStorage: Sendable {
    func save(_ token: StoredRefreshToken) throws
    func load() throws -> StoredRefreshToken?
    func delete() throws
}

public nonisolated final class KeychainTokenStorage: RefreshTokenStorage {
    private let service = "college.auth.refresh"
    private let account = "refresh_token"
    
    public init() {}
    
    public func save(_ token: StoredRefreshToken) throws {
        try delete()
        let data = try JSONEncoder().encode(token)
        let query: [String: Any] = [
            kSecClass as String             : kSecClassGenericPassword,
            kSecAttrService as String       : service,
            kSecAttrAccount as String       : account,
            kSecValueData as String         : data,
            kSecAttrAccessible as String    : kSecAttrAccessibleAfterFirstUnlock
        ]
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            CrashlyticsLogger.logKeychainError(
                operation: "save",
                status: status,
                key: service
            )
            throw APIError.keychainError(status: status)
        }
    }
    
    public func load() throws -> StoredRefreshToken? {
        let query: [String: Any] = [
            kSecClass as String           : kSecClassGenericPassword,
            kSecAttrService as String     : service,
            kSecAttrAccount as String     : account,
            kSecReturnData as String      : true,
            kSecMatchLimit as String      : kSecMatchLimitOne
        ]
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        if status == errSecItemNotFound { return nil }
        guard status == errSecSuccess, let data = item as? Data else {
            CrashlyticsLogger.logKeychainError(
                operation: "load",
                status: status,
                key: service
            )
            throw APIError.keychainError(status: status)
        }
        if let stored = try? JSONDecoder().decode(StoredRefreshToken.self, from: data) {
            return stored
        }
        guard let legacyToken = String(data: data, encoding: .utf8) else { return nil }
        return StoredRefreshToken(token: legacyToken, expiresAt: nil)
    }
    
    public func delete() throws {
        let query: [String: Any] = [
            kSecClass as String       : kSecClassGenericPassword,
            kSecAttrService as String : service,
            kSecAttrAccount as String : account
        ]
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            CrashlyticsLogger.logKeychainError(
                operation: "delete",
                status: status,
                key: service
            )
            throw APIError.keychainError(status: status)
        }
    }
}
