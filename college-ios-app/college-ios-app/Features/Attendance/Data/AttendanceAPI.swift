//
//  AttendanceAPI.swift
//  college-ios-app
//
//  Created by pc on 15.11.2025.
//

import Foundation

protocol AttendanceAPIProtocol {
    func fetchAttendance(start: Date, end: Date) async throws -> [AttendanceRecord]
}

final class AttendanceAPI: AttendanceAPIProtocol {
    private let client: HTTPClientProtocol
    
    init(client: HTTPClientProtocol) {
        self.client = client
    }
    
    func fetchAttendance(start: Date, end: Date) async throws -> [AttendanceRecord] {
        let queryItems = [
            URLQueryItem(name: "start", value: DateFormatters.request.string(from: start)),
            URLQueryItem(name: "end", value: DateFormatters.request.string(from: end))
        ]
        
        let endpoint = Endpoint(
            path: "/api/v1/attendance",
            method: .get,
            queryItems: queryItems
        )
        
        return try await client.send(endpoint, as: [AttendanceRecord].self)
    }
}
