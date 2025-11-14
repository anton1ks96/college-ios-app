//
//  APIError.swift
//  college-ios-app
//
//  Created by pc on 18.10.2025.
//

import Foundation

public enum APIError: LocalizedError, Sendable {
    // Network & Request errors
    case invalidBaseURL
    case requestBuildFailed
    case cancelled
    
    // Response errors
    case decodingFailed
    case unauthorized
    case forbidden
    case notFound
    case server(code: Int)
    case statusCode(Int, Data?)
    
    // Transport errors
    case transport(Error)
    case url(URLError)
    
    // Auth specific errors
    case missingRefreshToken
    case refreshFailed
    case signOutFailed
    case keychainError(status: OSStatus)
    
    public var errorDescription: String? {
        switch self {
        case .invalidBaseURL: return "Неверный адрес сервера."
        case .requestBuildFailed: return "Не удалось собрать запрос."
        case .cancelled: return "Запрос отменён."
        case .decodingFailed: return "Не удалось разобрать ответ сервера."
        case .unauthorized: return "Требуется авторизация."
        case .forbidden: return "Доступ запрещён."
        case .notFound: return "Ресурс не найден."
        case .server(let code): return "Ошибка сервера (\(code))."
        case .statusCode(let code, _): return "Сервер вернул код \(code)."
        case .transport(let err): return "Сетевая ошибка: \(err.localizedDescription)"
        case .url(let err): return err.localizedDescription
        case .missingRefreshToken: return "Refresh-токен отсутствует."
        case .refreshFailed: return "Не удалось обновить токены."
        case .signOutFailed: return "Не удалось выполнить выход."
        case .keychainError(let status): return "Ошибка Keychain (status: \(status))."
        }
    }
}
