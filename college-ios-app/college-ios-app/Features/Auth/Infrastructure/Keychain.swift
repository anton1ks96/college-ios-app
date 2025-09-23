//
//  Keychain.swift
//  college-ios-app
//
//  Created by pc on 24.09.2025.
//

import Foundation
import Security

final class Keychain {
    private let service: String
    private let account: String
    private let accessible = kSecAttrAccessibleWhenUnlockedThisDeviceOnly

    init(service: String, account: String) {
        self.service = service
        self.account = account
    }

    func save(_ secret: String) throws {
        let data = Data(secret.utf8)
        try? delete()

        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecAttrAccessible as String: accessible,
            kSecValueData as String: data
        ]

        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else { throw keychainErr(status) }
    }

    func read() throws -> String {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess, let data = item as? Data, let str = String(data: data, encoding: .utf8) else {
            throw keychainErr(status)
        }
        return str
    }

    func delete() throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else { throw keychainErr(status) }
    }

    private func keychainErr(_ status: OSStatus) -> NSError {
        NSError(domain: NSOSStatusErrorDomain, code: Int(status), userInfo: nil)
    }
}
