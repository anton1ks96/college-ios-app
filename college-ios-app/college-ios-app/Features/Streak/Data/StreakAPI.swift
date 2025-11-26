//
//  StreakAPI.swift
//  college-ios-app
//
//  Created by pc on 24.11.2025.
//

import Foundation

protocol StreakAPIProtocol {
    func fetchStreak() async throws -> StreakResponse
}

final class StreakAPI: StreakAPIProtocol {
    private let client: HTTPClientProtocol
    
    init(client: HTTPClientProtocol) {
        self.client = client
    }
    
    func fetchStreak() async throws -> StreakResponse {
        let endpoint = Endpoint(
            path: "/api/v1/attendance/streak",
            method: .get
        )
        
        return try await client.send(endpoint, as: StreakResponse.self)
    }
}
