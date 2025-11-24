//
//  PerformanceAPI.swift
//  college-ios-app
//
//  Created by pc on 19.11.2025.
//

import Foundation

protocol PerformanceAPIProtocol {
    func fetchSubjects() async throws -> [PerformanceSubject]
    func fetchScores(suID: String, start: Date, end: Date) async throws -> [PerformanceLesson]
}

final class PerformanceAPI: PerformanceAPIProtocol {
    private let client: HTTPClientProtocol
    
    private static let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .formatted(DateFormatters.request)
        return encoder
    }()
    
    init(client: HTTPClientProtocol) {
        self.client = client
    }
    
    func fetchSubjects() async throws -> [PerformanceSubject] {
        let endpoint = Endpoint(
            path: "/api/v1/performance/subjects",
            method: .get
        )
        
        do {
            return try await client.send(endpoint, as: [PerformanceSubject].self)
        } catch {
            CrashlyticsLogger.logNetworkError(
                error,
                endpoint: "/api/v1/performance/subjects",
                method: "GET"
            )
            throw error
        }
    }
    
    func fetchScores(suID: String, start: Date, end: Date) async throws -> [PerformanceLesson] {
        struct Body: Encodable {
            let suID: String
            let datastart: String
            let dataend: String
            
            enum CodingKeys: String, CodingKey {
                case suID = "SuID"
                case datastart
                case dataend
            }
        }
        
        let body = Body(
            suID: suID,
            datastart: DateFormatters.request.string(from: start),
            dataend: DateFormatters.request.string(from: end)
        )
        
        let bodyData = try Self.encoder.encode(body)
        
        let endpoint = Endpoint(
            path: "/api/v1/performance/score",
            method: .post,
            body: bodyData,
            contentType: "application/json"
        )
        
        do {
            let response = try await client.send(endpoint, as: PerformanceResponse.self)
            return response.lessons
        } catch {
            CrashlyticsLogger.logNetworkError(
                error,
                endpoint: "/api/v1/performance/score",
                method: "POST"
            )
            throw error
        }
    }
}
