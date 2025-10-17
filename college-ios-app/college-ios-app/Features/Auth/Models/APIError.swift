//
//  APIError.swift
//  college-ios-app
//
//  Created by pc on 18.10.2025.
//

import Foundation

public enum APIError: LocalizedError, Sendable {
    case invalidBaseURL
    case requestBuildFailed
    case decodingFailed
    case unauthorized           
    case forbidden
    case notFound
    case server(code: Int)
    case transport(Error)
    case missingRefreshToken
    case refreshFailed
    case signOutFailed
    case keychainError(status: OSStatus)

    public var errorDescription: String? {
        switch self {
        case .invalidBaseURL: return "Неверный адрес сервера."
        case .requestBuildFailed: return "Не удалось собрать запрос."
        case .decodingFailed: return "Не удалось разобрать ответ сервера."
        case .unauthorized: return "Требуется авторизация."
        case .forbidden: return "Доступ запрещён."
        case .notFound: return "Ресурс не найден."
        case .server(let code): return "Ошибка сервера (\(code))."
        case .transport(let err): return "Сетевая ошибка: \(err.localizedDescription)"
        case .missingRefreshToken: return "Refresh-токен отсутствует."
        case .refreshFailed: return "Не удалось обновить токены."
        case .signOutFailed: return "Не удалось выполнить выход."
        case .keychainError(let status): return "Ошибка Keychain (status: \(status))."
        }
    }
}
