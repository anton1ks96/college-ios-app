//
//  Keychain.swift
//  college-ios-app
//
//  Created by pc on 17.10.2025.
//

import Foundation
import Security

public protocol RefreshTokenStorage: Sendable {
    func save(_ token: String) throws
    func load() throws -> String?
    func delete() throws
}

public final class KeychainTokenStorage: RefreshTokenStorage {
    private let service = "college.auth.refresh"
    private let account = "refresh_token"
    
    public init() {}
    
    public func save(_ token: String) throws {
        try delete()
        let data = Data(token.utf8)
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
    
    public func load() throws -> String? {
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
        return String(data: data, encoding: .utf8)
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
