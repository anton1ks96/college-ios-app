//
//  AuthAPI.swift
//  college-ios-app
//
//  Created by pc on 18.10.2025.
//

import Foundation

public final class AuthAPI: @unchecked Sendable {
    private let client: AFHTTPClient
    
    private static let encoder: JSONEncoder = {
        let e = JSONEncoder()
        e.keyEncodingStrategy = .convertToSnakeCase
        return e
    }()
    
    public init(client: AFHTTPClient) {
        self.client = client
    }
    
    // MARK: - Public endpoints
    
    public func signIn(username: String, password: String) async throws -> SignInResponse {
        struct Body: Encodable { let username: String; let password: String }
        let bodyData = try Self.encoder.encode(Body(username: username, password: password))
        let endpoint = Endpoint(
            path: "auth/api/v1/app/signin",
            method: .post,
            body: bodyData,
            contentType: "application/json"
        )
        return try await client.send(endpoint)
    }
    
    public func getAccessToken(refreshToken: String) async throws -> AccessTokenResponse {
        struct Body: Encodable { let refreshToken: String }
        let bodyData = try Self.encoder.encode(Body(refreshToken: refreshToken))
        let endpoint = Endpoint(
            path: "auth/api/v1/app/access",
            method: .post,
            body: bodyData,
            contentType: "application/json"
        )
        return try await client.send(endpoint)
    }
    
    public func refreshRefreshToken(refreshToken: String) async throws -> RefreshTokenResponse {
        struct Body: Encodable { let refreshToken: String }
        let bodyData = try Self.encoder.encode(Body(refreshToken: refreshToken))
        let endpoint = Endpoint(
            path: "auth/api/v1/app/refresh",
            method: .post,
            body: bodyData,
            contentType: "application/json"
        )
        return try await client.send(endpoint)
    }
    
    public func signOut(refreshToken: String) async throws {
        struct Body: Encodable { let refreshToken: String }
        struct Empty: Decodable {}
        let bodyData = try Self.encoder.encode(Body(refreshToken: refreshToken))
        let endpoint = Endpoint(
            path: "auth/api/v1/app/signout",
            method: .post,
            body: bodyData,
            contentType: "application/json"
        )
        let _: Empty = try await client.send(endpoint)
    }
    
    public func validate(accessToken: String) async throws -> ValidateResponse {
        struct Empty: Encodable {}
        let bodyData = try Self.encoder.encode(Empty())
        let endpoint = Endpoint(
            path: "auth/api/v1/app/validate",
            method: .post,
            headers: ["Authorization": "Bearer \(accessToken)"],
            body: bodyData,
            contentType: "application/json"
        )
        return try await client.send(endpoint)
    }
}
