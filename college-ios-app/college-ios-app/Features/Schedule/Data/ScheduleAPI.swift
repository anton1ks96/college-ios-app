//
//  ScheduleAPI.swift
//  college-ios-app
//
//  Created by pc on 21.09.2025.
//

import Foundation

protocol ScheduleAPIProtocol {
    func fetchSchedule(
        group: String,
        subgroup: String,
        start: Date,
        end: Date
    ) async throws -> ScheduleResponse
}

final class ScheduleAPI: ScheduleAPIProtocol {
    private let client: HTTPClientProtocol

    init(client: HTTPClientProtocol) {
        self.client = client
    }

    func fetchSchedule(
        group: String,
        subgroup: String,
        start: Date,
        end: Date
    ) async throws -> ScheduleResponse {
        let endpoint = Endpoint(
            path: "/api/v1/schedule",
            method: .get,
            queryItems: [
                URLQueryItem(name: "group", value: group),
                URLQueryItem(name: "subgroup", value: subgroup),
                URLQueryItem(name: "start", value: DateFormatters.request.string(from: start)),
                URLQueryItem(name: "end", value: DateFormatters.request.string(from: end))
            ]
        )
        return try await client.send(endpoint, as: ScheduleResponse.self)
    }
}
